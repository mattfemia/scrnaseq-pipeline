#!/bin/bash/env nextflow
nextflow.enable.dsl=2

params.outdir = 'results'

process FASTQC {
    tag "FASTQC on $sample_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}_logs" 

    script:
    """
    bash ${projectDir}/src/bash/fastqc.sh "$sample_id" "$reads"
    """
}
