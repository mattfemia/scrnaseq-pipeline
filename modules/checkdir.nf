#!/bin/bash/env nextflow
nextflow.enable.dsl=2

process CHECKDIR {
  input:
  path genes
  
  output:
  path genes

  script:
  """
  bash ${projectDir}/src/bash/check_data.sh -p $projectDir
  """
}