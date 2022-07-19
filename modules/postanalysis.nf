#!/bin/bash/env nextflow
nextflow.enable.dsl=2

process POSTANALYSIS {
    publishDir "$baseDir/outs", mode: 'copy'
    echo true

    input:
    path genes

    script:
    """
    bash ${projectDir}/src/bash/setup_analysis.sh -p $projectDir
    python3 ${projectDir}/src/python/analysis.py --path $projectDir/data/raw_feature_bc_matrix --outdir $projectDir
    """
}
