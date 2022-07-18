# scRNA-seq Pipeline
[![Build Status](https://app.travis-ci.com/mattfemia/scrnaseq-pipeline.svg?branch=master)](https://app.travis-ci.com/mattfemia/scrnaseq-pipeline)
[![codecov](https://codecov.io/gh/mattfemia/scrnaseq-pipeline/branch/master/graph/badge.svg?token=guV5fVIYcy)](https://codecov.io/gh/mattfemia/scrnaseq-pipeline) 
 ![version](https://img.shields.io/badge/version-0.0.1b2-blue)  
  
### **Nextflow pipeline for reproducible parallel analysis of scRNA-seq data**.
  
## Contents
1. [Introduction](##Introduction)
2. [Data](##Data)
3. [Analysis](##Analysis)
4. [Pipeline-Environments](##Pipeline-Environments)
   1. [Docker](###Docker)
   2. [AWS Batch / Terraform](###awsbatch)
   3. [Nextflow / Local](###local)
5. [Technology](##Technology)

  
## Introduction  
The purpose here is to provide a standard, pre-built bioinformatics infrastructure for processing single-cell RNA sequencing (scRNA-seq) files generated primarily with 10X Genomics' Chromium controllers / library prep (however, the pipeline could be easily modified to exclude these pre-processing steps and work directly with FASTQ files - please submit an issue ticket for assistance).  
  
The overall goal is to promote reproducible research and more generally, reproducible and streamlined bioinformatics workflows.  
  
The pipeline uses [Nextflow](https://www.nextflow.io/) for orchestrating reproducible parallel analysis of scRNA-seq data across compute environments. It has the flexibility to be run as a dockerized solution, deployed through several batch-processing executors (i.e. AWS Batch, Slurm, GCP, etc.), or built and executed locally.

The analysis workflow involves:
  
* Demultiplex Illumina-sequencer-generated BCL files
* Generate FASTQ files using CellRanger
* QC / MultiQC on FASTA & FASTQ files
* Post-analysis of raw_feature_bc_matrices
* Generate final figures/visuals
  
A sample post-analysis file can be found in [src/python/analysis.py](src/python/analysis.py), however, the contents of the file can and should be replaced with **any** analysis.
  
## Data
  
The pipeline expects data to be in the /data directory in the root of the repo. Alternatively, users can point to an AWS S3 bucket or similar blob/file storage by changing these properties in [nextflow.config](nextflow.config). For more information on editing this Nextflow configuration, read more [here](https://www.nextflow.io/docs/latest/amazons3.html)

## Analysis
  
The contents in [python/analysis.py](python/analysis.py) provide a basic example of scRNA post-analysis. However, *any* analysis can replace the contents of this file and run accordingly.

## Pipeline-Environments
  
Different options are available to run the pipeline using various configurations in this repo:  
  
### Docker  
  
The pipeline is containerized and can be run as-is with the following commands
to execute the pipeline on sample data in the data/ directory:

Build:  

        docker build -f docker/Dockerfile -t scrna-pipeline .
        
  
To run:  

        docker run scrna-pipeline
        
  
The data/ directory should be the entry point for adding data files
  
A containerized image of the CellRanger pipeline can also be easily built and deployed
locally or through a cloud integration like AWS ECS or AWS Batch.  
  
The Docker image is also publicly available and hosted on DockerHub and can be pulled down:

Stable version:  

        docker pull mattfemia/scrna-pipeline:0.0.1-dev
        
Latest:  

        docker pull mattfemia/scrna-pipeline:0.0.1-dev
        
### AWS Batch / Terraform <a name="awsbatch"></a>
  
For current AWS users looking to configure the pipeline with AWS Batch, the resources infrastructure can be set-up automatically by configuring the terraform files found in the [terraform/](/terraform) directory.
  
#### AWS Infrastructure  
When configured, the following resources will be initialized and managed in terraform state:  
  
- S3 Bucket (Private Access)
- Batch Compute Environment (with Fargate)
- Batch Job Queue
- VPC
  
#### Configuration
To configure:  
  
- Update the `provider "aws" {...}` block in [terraform/main.tf](/terraform/main.tf) to include your AWS credentials. More information can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration)
- Update the bucket name in [nextflow.config](nextflow.config) for the `profiles {'batch': ...}` and `profiles {'s3-data': ...}` entries
- (Optional) If state is managed with Terraform Cloud or with a VCS rather than locally, uncomment and edit the `backend "remote" {...}` block in [terraform/main.tf](/terraform/main.tf)
- (Optional) Update the S3 bucket name by editing the `resource "aws_s3_bucket" "pipeline_bucket" {...}` block
  
#### Deploying Infrastructure
A basic walkthrough of Terraform can be found [here](https://learn.hashicorp.com/collections/terraform/aws-get-started?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS). However the following shell commands will perform setup:
  
1. To initialize your project directory:

        terraform init
          
2. Check formatting of file after editing:

        terraform fmt
        
3. Deploy changes (*WARNING: You **will** be charged for AWS resources after deploying*):

        terraform apply
        
4. Finally, to teardown resources:
        terraform destroy
        
These commands are also available in [terraform/tf.sh](terraform/tf.sh)  
  
### Nextflow / Local Pipeline <a name="local"></a>
  
#### Requirements
  
* Unix-like operating system (Linux, macOS, etc)
* Java 8
* [Salmon](https://combine-lab.github.io/salmon/) 1.0.0
* [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) 0.11.5
* [Multiqc](https://multiqc.info) 1.5

The following steps can be used to run the pipeline locally using [Nextflow](https://www.nextflow.io/)  
  
1. If you don't have it already install Docker in your computer. Read more [here](https://docs.docker.com/).

2. Install Nextflow (version 20.07.x or higher):
      
      curl -s https://get.nextflow.io | bash

3. (Optional) If `Salmon`, `FastQC`, and `Multiqc` are not installed, you can add these to your current conda environment by updating the <`conda-env`> and then running:

      conda env update --name <conda-env> --file conda.yml --prune
        
4. Launch the pipeline execution: 

      ./nextflow run nextflow-io/rnaseq-nf -with-docker
        
5. When the execution completes open in your browser the report generated at the following path:

      results/multiqc_report.html 
	
You can see an example report at the following [link](http://multiqc.info/examples/rna-seq/multiqc_report.html).

### Technology
  
- Nextflow
- FastQC
- Multiqc
- Salmon
- CellRanger
- Python
  - Scanpy
  - unittest
- Terraform
- AWS
  - Batch
  - S3
  - VPC
  - Fargate
- GNU make
- Conda
- Travis CI