#!/usr/bin python3
#analysis.py

import argparse
import scanpy as sc
import pandas as pd

def hello():
    return 'hello'

def get_args(argv=None):

    parser = argparse.ArgumentParser(description = "Specify path to count matrix")
    parser.add_argument('--path', metavar='path', type=str, help='Specify path to count matrix directory')
    parser.add_argument('--outdir', metavar='outdir', type=str, help='Specify path to project directory')
    
    args = parser.parse_args(argv)
    path = args.path
    outdir = args.outdir
    
    return (path, outdir)

def setup_anndata(path: str):

    # Init anndata obj
    adata = sc.read_10x_mtx(
        path, 
        var_names='gene_symbols', 
        cache=True)

    return adata

def plot_top_genes(adata, count: int):

    adata.var_names_make_unique()
    sc.pl.highest_expr_genes(adata, n_top=count, )

    return adata

def apply_qc(adata, min_genes=200, min_cells=3, pct_mito=5, norm_target=1e4):

    # Filter on minimum # of genes per cell + minimum cells expressing x genes
    sc.pp.filter_cells(adata, min_genes=min_genes)
    sc.pp.filter_genes(adata, min_cells=min_cells)

    # Setup filter for cells with high pct of mt-gene for cell viability
    adata.var['mt'] = adata.var_names.str.startswith('MT-')
    sc.pp.calculate_qc_metrics(adata, qc_vars=['mt'], percent_top=None, log1p=False, inplace=True)

    # Save plots to outs for assessing/tuning filtering after
    sc.pl.violin(
        adata, 
        ['n_genes_by_counts', 'total_counts', 'pct_counts_mt'],
        jitter=0.4, 
        multi_panel=True)
    sc.pl.scatter(adata, x='total_counts', y='pct_counts_mt')
    sc.pl.scatter(adata, x='total_counts', y='n_genes_by_counts')
    
    # Apply filter to obs struct in AnnData obj
    adata = adata[adata.obs.n_genes_by_counts < 2500, :]
    adata = adata[adata.obs.pct_counts_mt < 5, :]

    # Normalize transcripts
    sc.pp.normalize_total(adata, target_sum=norm_target)
    sc.pp.log1p(adata)

    return adata

def calc_variable_genes(adata):

    sc.pp.highly_variable_genes(adata, min_mean=0.0125, max_mean=3, min_disp=0.5) # Calc
    sc.pl.highly_variable_genes(adata) # Plot
    adata.raw = adata
    adata = adata[:, adata.var.highly_variable] # Subset
    
    return adata

def run_pca(adata, outfile: str):

    sc.pp.regress_out(adata,['total_counts', 'pct_counts_mt'])
    sc.pp.scale(adata,max_value=10)
    sc.tl.pca(adata,svd_solver='arpack')
    sc.pl.pca(adata, color='GAPDH')
    sc.pl.pca_variance_ratio(adata,log=True)
    adata.write(outfile)

    return adata

def run_neighbors(adata):
    
    sc.pp.neighbors(adata,n_neighbors=10, n_pcs=40)
    sc.tl.umap(adata)
    sc.pl.umap(adata, color=['CST3', 'NKG7', 'GAPDH'], use_raw=False)

    return adata

def run_leiden_cluster(adata, outfile):
    
    sc.tl.leiden(adata)
    sc.pl.umap(adata, color=['leiden', 'CST3', 'NKG7'])
    adata.write(outfile)

    return adata

def rank_genes(adata, outfile, outdir):
    
    sc.tl.rank_genes_groups(adata, 'leiden', method='t-test')
    sc.pl.rank_genes_groups(adata, n_genes=25, sharey=False)

    sc.tl.rank_genes_groups(adata, 'leiden', method='wilcoxon')
    sc.pl.rank_genes_groups(adata, n_genes=25, sharey=False)

    adata.write(outfile)

    sc.tl.rank_genes_groups(adata, 'leiden', method='logreg')
    sc.pl.rank_genes_groups(adata, n_genes=25, sharey=False)
    adata = sc.read(outfile)
    adata.uns['log1p']["base"] = None # bug workaround for scanpy v1.9.1
    
    pd.DataFrame(adata.uns['rank_genes_groups']['names']).to_csv(f'{outdir}/gene_rank.csv')
    result = adata.uns['rank_genes_groups']
    groups = result['names'].dtype.names
    pd.DataFrame(
        {group + '_' + key[:1]: result[key][group]
        for group in groups for key in ['names', 'pvals']}).to_csv(f'{outdir}/scored_rank.csv')

    sc.tl.rank_genes_groups(adata,'leiden', groups=['0'], reference='1', method='wilcoxon')
    sc.pl.rank_genes_groups(adata, groups=['0'], n_genes=20)

    sc.pl.rank_genes_groups_violin(adata, groups='0', n_genes=8)

    adata = sc.read(outfile)
    sc.pl.rank_genes_groups_violin(adata, groups='0', n_genes=8)

    sc.pl.violin(adata, ['CST3', 'NKG7', 'GAPDH'], groupby='leiden')

    return adata

def plot_marker_clusters(adata):
    marker_genes = ['IL7R', 'CD79A', 'MS4A1', 'CD8A', 'CD8B', 'LYZ', 'CD14',
            'LGALS3', 'S100A8', 'GNLY', 'NKG7', 'KLRB1',
            'FCGR3A', 'MS4A7', 'FCER1A', 'CST3']
    new_cluster_names = [
        'CD4 T', 'CD14 Monocytes',
        'B', 'CD8 T',
        'NK', 'FCGR3A Monocytes',
        'Dendritic', 'Megakaryocytes']
    # adata = adata.rename_categories('leiden', new_cluster_names)
    sc.pl.umap(adata, color='leiden', legend_loc='on data', title='', frameon=False)

    sc.pl.dotplot(adata, marker_genes, groupby='leiden')
    sc.pl.stacked_violin(adata, marker_genes, groupby='leiden', rotation=90)

    return adata

def main():

    # Get args
    path, outdir = get_args()
    results_file = f'{outdir}/data/pbmc3k.h5ad'

    # Config 
    # ----------------------------------------------------------------------- #
 
    # Global params for Scanpy
    sc.settings.verbosity = 4 # Capture all stdout and stderr
    sc.settings.logfile = f"{outdir}/logs/runtime.txt" # Explicitly stating the Scanpy default
    sc.settings.figdir = f'{outdir}/figures/' # Explicitly stating the Scanpy default
    sc.settings.datasetdir = f'{outdir}/data/analysis/' # Tabular exports
    sc.settings.file_format_data = 'csv' # Tabular export file ext
    sc.settings.writedir = f'{outdir}/data/analysis/' # Save loc for sc.write -- AnnData exports
    sc.settings.autosave = True # Autosave figs on render
    sc.settings.autoshow = False # Disable showing figs on render
    
    # Set low until EC2 benchmarking with CellRanger finished
    sc.settings.n_jobs = 8 # Num of CPU/jobs
    
    # Set figure export to high DPI and tif ext for publication quality figs
    sc.settings.set_figure_params(
        dpi_save=300, 
        format="tif", 
    )

    # Runner
    # ----------------------------------------------------------------------- #
    adata = setup_anndata(path=path)
    adata = plot_top_genes(adata, count=20)
    adata = apply_qc(adata, min_genes=200, min_cells=3, pct_mito=5, norm_target=1e4)
    adata = calc_variable_genes(adata)
    adata = run_pca(adata, outfile=results_file)
    adata = run_neighbors(adata)
    adata = run_leiden_cluster(adata, outfile=results_file)
    adata = rank_genes(adata, outfile=results_file, outdir=sc.settings.datasetdir)
    adata = plot_marker_clusters(adata)

    return adata

if __name__ == '__main__':
    main()
