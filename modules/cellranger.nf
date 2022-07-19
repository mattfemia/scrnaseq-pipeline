#!/bin/bash/env nextflow
nextflow.enable.dsl=2

// Pre-filled params for demonstrative purposes
params.fastq_dir="$projectDir/fastq"
params.sample_id="pipeline_sample"
params.sample_name="pbmc_1k_v3" // This is using the test data downloaded in the Dockerfile

fastq_ch = Channel
            .fromPath(params.fastq_dir)
            .view()

process cellranger_count {
    publishDir "$baseDir/outs", mode: 'copy'
    echo true

    input:
    path fastq_ch
        
    script:
    """
    cellranger count --id=${params.sample_id} \
    --fastqs=${fastq_ch} \
    --sample=${params.sample_name} \
    --transcriptome=/opt/refdata-gex-GRCh38-2020-A
    """
}

workflow {
    cellranger_count(fastq_ch)
}

workflow.onComplete {
  println (workflow.success ? "Successfully completed pipeline." : "Error occurred in pipeline")
}