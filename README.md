# scRNA-seq Pipeline

**Nextflow pipeline using CellRanger and Scanpy for reproducible parallel analysis of scRNA-seq data**.

## Status:
**In-progress**

## Introduction  
This pipeline uses Nextflow for orchestrating reproducible analysis of 
scRNA-seq data across compute environments. It has the flexibility to be
deployed as a containerized solution or built and executed locally.

The analysis flow involves:  
* CellRanger analysis pipeline using FASTQ files
* Post-analysis Scanpy

## Docker
A containerized image of this pipeline can quickly be built and deployed
locally or through a cloud integration like AWS ECS.  
  
The Dockerfile instructs the setup of multiple pipeline dependencies:  
- Python and required packages
- Java via openjdk
- NextFlow
- CellRanger-6.0.1
- GRCh38-2020-A Reference for CellRanger
  
All of these can be customized, however each is required in some capacity for
everything to function properly.  
  
CellRanger is downloaded via a hosted option from umassmed.edu. This 
design decision was to avoid the self-expiring, signedURL version available on 
10XGenomics official site. The latter can be used, but keep in mind the 
deployment will fail any wget/curl executions after the URL expires -- and 
therefore won't be sustainable in a CI/CD deployment. You will have to download
and host directly if you choose to change this or use CellRanger-3.*.* available
in several places, but lacking many newer features.

To build:
```
docker build -t scpipeline .
```
  
To run:
```
docker run -it scpipeline sh
cd /opt
nextflow run main.nf
```  
  
Or optionally add a CMD directive to the Dockerfile to automatically execute the
run command. This was intentionally left out at the moment to extend flexibility

## AWS EC2 Instance Storage Option
If choosing to manually set-up and run docker container with /fastq/data 
directly on EC2 (rather than S3 and/or Batch), either through ECR-->ECS or 
UserData-->EC2-init, it will be costly to scale EBS volumes for large amounts 
of sequencing data. As an alternative, I would recommend selecting an EC2 
instance type that has available instance storage. This would allow for enough 
storage capacity to ingest your files and then recycle data as your pipeline 
progresses.  
  
This strategy could also be used to quickly test or run/debug forks 
of this pipeline.
  
To mount:
1. SSH into EC2 instance: 
```
ssh -i /path/keypair.pem instance@public-dns
```

2. Check mapped volumes that are not mounted: 
```
lsblk
```

3. Make filesystem from volume, where nvme1n1 is your unmounted volume from lsblk
```
sudo mkfs -t xfs /dev/nvme1n1
```

4. Create a directory to mount: 
```
sudo mkdir /data
```

5. Mount fs to directory:
```
sudo mount /dev/nvme1n1 /data
```
