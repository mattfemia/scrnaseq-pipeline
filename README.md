# scRNA-seq Pipeline
[![Build Status](https://app.travis-ci.com/mattfemia/scrnaseq-pipeline.svg?branch=master)](https://app.travis-ci.com/mattfemia/scrnaseq-pipeline)
 ![version](https://img.shields.io/badge/version-0.0.1b2-blue)  
  
**Nextflow pipeline using Scanpy for quick and reproducible parallel post-analysis of scRNA-seq data**.

## Introduction  
This pipeline uses Nextflow for orchestrating reproducible parallel analysis of 
scRNA-seq data across compute environments. It has the flexibility to be
deployed as a containerized solution and deployed through several executors 
(i.e. AWS Batch, Slurm, GCP, etc.) or built and executed locally.

The analysis workflow involves:  
* Processing of raw sequencing files  
* QC / MultiQC on FASTA & FASTQ files
* CellRanger analysis pipeline using FASTQ files
* Post-analysis of raw_feature_bc_matrices
  
## Pipeline Environments
  
### Docker  
  
The pipeline is containerized and can be run as-is with the following commands
to execute the pipeline on sample data in the data/ directory:

Build:  
```
docker build -f docker/Dockerfile -t scrna-pipeline .
```
  
To run:  
```
docker run scrna-pipeline
```  
  
The data/ directory should be the entry point for adding data files
  
A containerized image of the CellRanger pipeline can also be easily built and deployed
locally or through a cloud integration like AWS ECS or AWS Batch.  
  
The Docker image is also publicly available and hosted on DockerHub and can be pulled down:

Stable version:  
```
docker pull mattfemia/scrna-pipeline:0.0.1-dev
```  
  
Latest:  
```
docker pull mattfemia/scrna-pipeline:0.0.1-dev
```  
  

### AWS Batch / Terraform 
  
For current AWS users looking to configure the pipeline with AWS Batch, the resources infrastructure can be set-up automatically by configuring the terraform files found in the [terraform/](/terraform) directory.
  
#### AWS Infrastructure  
When configured, the following resources will be initialized and managed in terraform state:  
  
- S3 Bucket (Private Access)
- Batch Compute Environment (with Fargate)
- Batch Job Queue
- VPC
  
#### Configuration
To configure:  
  
- Update the `provider "aws" {...}` block in [terraform/main.tf](/terraform/main.nf) to include your AWS credentials. More information can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration)
- (Optional) If state is managed with Terraform Cloud or with a VCS rather than locally, uncomment and edit the `backend "remote" {...}` block in [terraform/main.tf](/terraform/main.nf)
- (Optional) Update the S3 bucket name by editing the `resource "aws_s3_bucket" "pipeline_bucket" {...}` block
  
#### Deploying Infrastructure
A basic walkthrough of Terraform can be found [here](https://learn.hashicorp.com/collections/terraform/aws-get-started?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS). However the following shell commands will perform setup:
  
1. To initialize your project directory:
  
  `terraform init`
  
2. Check formatting of file after editing:
  
  `terraform fmt`
  
3. Deploy changes (*WARNING: You **will** be charged for AWS resources after deploying*):
  
  `terraform apply`

4. Finally, to teardown resources:
  
  `terraform destroy`
  
These commands are also available in [terraform/tf.sh](terraform/tf.sh)  
  
### Nextflow / Local Pipeline  
  
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

3. Launch the pipeline execution: 

        ./nextflow run nextflow-io/rnaseq-nf -with-docker
        
4. When the execution completes open in your browser the report generated at the following path:

        results/multiqc_report.html 
	
You can see an example report at the following [link](http://multiqc.info/examples/rna-seq/multiqc_report.html).

### Technology