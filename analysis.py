#!/usr/bin python3
#analysis.py

import os
import argparse
import scanpy as sc
import anndata

def get_args():

    parser = argparse.ArgumentParser(description = "Specify path to count matrix")
    parser.add_argument('--path', metavar='path', type=str, help='Specify path to count matrix directory')
    parser.add_argument('--outdir', metavar='outdir', type=str, help='Specify path to project directory')
    
    args = parser.parse_args()
    path = args.path
    outdir = args.outdir

    return (path, outdir)

def setup_anndata(path):

    # Init anndata obj
    adata = sc.read_10x_mtx(
        path, 
        var_names='gene_symbols', 
        cache=True)

    return adata

def plot_top_genes(adata, count):

    adata.var_names_make_unique()
    sc.pl.highest_expr_genes(adata, n_top=count, )

    return 0

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
    adata = adata[:, adata.var.highly_variable] # Subset
    
    return adata

def run_pca(adata):

    sc.pp.regress_out(ad, ['total_counts', 'pct_counts_mt'])
    sc.pp.scale(ad, max_value=10)
    
def main():

    # Get args
    path, outdir = get_args()

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
    
    # TODO:  
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
    plot_top_genes(adata=adata, count=20)
    adata = apply_qc(adata, min_genes=200, min_cells=3, pct_mito=5, norm_target=1e4)

if __name__ == '__main__':
    main()
