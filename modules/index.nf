#!/bin/bash/env nextflow
nextflow.enable.dsl=2

process INDEX {
    tag "$transcriptome.simpleName"

    input:
    path transcriptome 

    output:
    path 'index' 

    script:
    """
    salmon index --threads $task.cpus -t $transcriptome -i index
    """
}
