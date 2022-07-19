#!/bin/bash/env nextflow
nextflow.enable.dsl=2

// import modules
include { POSTANALYSIS } from './modules/postanalysis.nf'
include { CHECKDIR } from './modules/checkdir.nf'
include { RNASEQ } from './modules/rnaseq'
include { MULTIQC } from './modules/multiqc'

params.reads = "$baseDir/data/ggal/ggal_gut_{1,2}.fq"
params.transcriptome = "$baseDir/data/ggal/transcriptome.fa"
params.outdir = "results"
params.multiqc = "$baseDir/multiqc"

gene_ch = Channel
            .fromPath("$projectDir/data/raw_feature_bc_matrix")
            .view()

log.info """\
 S E Q R E P R   P I P E L I N E
 ===================================
 transcriptome: ${params.transcriptome}
 reads        : ${params.reads}
 outdir       : ${params.outdir}
 qc_min_genes : ${params.qc_min_genes}
 qc_min_cells : ${params.qc_min_cells}
 qc_norm_cell : ${params.qc_norm_cell_count}
 pca_color    : ${params.pca_color}
 umap_color   : ${params.umap_color}
 cluster_mkrs : ${params.cluster_markers}
 figure_fmt   : ${params.figure_format}
 figure_dpi   : ${params.figure_dpi}
 cpu_count:   : ${params.cpu_count}
 """

workflow {
  CHECKDIR( gene_ch ) | POSTANALYSIS
  read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
  RNASEQ( params.transcriptome, read_pairs_ch )
  MULTIQC( RNASEQ.out, params.multiqc )
}

workflow.onComplete {
  println (workflow.success ? "Successfully completed pipeline." : "Error occurred in pipeline")
}