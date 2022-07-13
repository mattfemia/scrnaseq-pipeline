#!/bin/bash/env nextflow
nextflow.enable.dsl=2

gene_ch = Channel
            .fromPath("$projectDir/data/raw_feature_bc_matrix")
            .view()

process checkDataDir {
  input:
  path genes
  
  output:
  path genes

  script:
  """
  bash ${projectDir}/src/bash/check_data.sh -p $projectDir
  """
}

process runScanpy {
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

workflow {
  checkDataDir(gene_ch) | runScanpy
}

workflow.onComplete {
  println (workflow.success ? "Successfully completed pipeline." : "Error occurred in pipeline")
}