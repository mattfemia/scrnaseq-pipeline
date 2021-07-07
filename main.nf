#!/bin/bash/env nextflow

nextflow.enable.dsl=2

// params.genes = "$baseDir/data"
params.analysis_file = "$projectDir/src/python/analysis.py"

gene_ch = Channel
            .fromPath("$projectDir/data/raw_feature_bc_matrix")
            .view()

process runScanpy {
    publishDir "$baseDir/outs", mode: 'copy'
    echo true

    input:
    path genes

    script:
    """
    bash ${projectDir}/src/bash/setup_analysis.sh -p $projectDir
    python3 ${projectDir}/src/python/analysis.py --path $genes --outdir $projectDir
    """
}

workflow {
    runScanpy(gene_ch)
}

workflow.onComplete {
  println (workflow.success ? "Successfully completed pipeline." : "Error occurred in pipeline")
}