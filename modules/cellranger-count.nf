#!/bin/bash/env nextflow
nextflow.enable.dsl=2

process CELLRANGER_COUNT {
    publishDir "$baseDir/outs", mode: 'copy'
    echo true

    input:
    path fastq_ch
    
    output:
    path "$baseDir/outs/${params.sample}/outs/raw_feature_bc_matrix"
    
    script:
    """
    cellranger count --id=${params.sample_id} \
    --fastqs=${fastq_ch} \
    --sample=${params.sample_name} \
    --transcriptome=${params.transcriptome}
    """
}