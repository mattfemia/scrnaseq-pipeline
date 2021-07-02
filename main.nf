#!/bin/bash/env nextflow

nextflow.enable.dsl=2

// params.genes = "$baseDir/data"
params.scanpy = "$projectDir/scanpy.py"


gene_ch = Channel
            .fromPath('data/raw_feature_bc_matrix')
            .view()

process createScanpy {
    publishDir "$baseDir/outs", mode: 'copy'
    echo true

    input:
    path genes

    script:
    """
    echo ${projectDir}/analysis.py
    mkdir -p $projectDir/logs $projectDir/figures
    mkdir -p $projectDir/data/analysis
    touch $projectDir/logs/metadata.txt $projectDir/logs/runtime.txt
    python3 ${projectDir}/analysis.py --path $genes --outdir $projectDir
    """
}

workflow {
    createScanpy(gene_ch)
}