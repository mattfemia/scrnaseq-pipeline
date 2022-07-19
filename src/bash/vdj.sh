#!/bin/bash

cd /data/runs
cellranger vdj --id=sample345 \
                --reference=/opt/refdata-cellranger-vdj-GRCh38-alts-ensembl-5.0.0 \
                --fastqs=/data/jdoe/runs/HAWT7ADXX/outs/fastq_path \
                --sample=mysample \
                --localcores=8 \
                --localmem=64