#!/bin/bash

# Tested on m5.8xlarge with 200GB block storage
# --------------------------------------------------------------------------- #
# Mount Instance Storage steps:
# --------------------------------------------------------------------------- #

# 1. SSH into EC2 instance: 
ssh -i /path/keypair.pem instance@public-dns

# 2. Check mapped volumes that are not mounted: 
lsblk

# 3. Make filesystem from volume, where nvme1n1 is your unmounted volume from lsblk
sudo mkfs -t xfs /dev/nvme1n1

# 4. Create a directory to mount: 
sudo mkdir /data
sudo chown -R ec2-user:ec2-user /data

# 5. Mount fs to directory:
sudo mount /dev/nvme1n1 /data

# --------------------------------------------------------------------------- #
# Env setup
# --------------------------------------------------------------------------- #

# java
sudo amazon-linux-extras install -y java-openjdk11

# Nextflow
curl -s https://get.nextflow.io | bash

# Python and pip
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable python3.8
sudo yum install python38
python3 --version
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user

# Add to path
ls -a ~ # Use output of this as LOCAL_PATH
export PATH=LOCAL_PATH:$PATH
source ~/.bashrc # Profile script should be the bashprofile
pip --version

# Cellranger 7.0.0 download
cd /opt
sudo wget -O cellranger-7.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.0.0.tar.gz?Expires=1658295882&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NTgyOTU4ODJ9fX1dfQ__&Signature=nfrGaqnurk4Ra1~8Nd4US1pq8yKCRpqGJtyyOzd2xRhkOF2~XFiPslLgZ1F8Ow-1jqSrrGgoW-DlKOIJdkdL7hOz0IGAtKpz8Ei7MyPe4g0j~0Yw9QC3OPmheSz5p1kgAMOfJ-GvA5D7aJpfxTYI1Wp73cvTWtrQBLHmxAb7zuwuqBSHdnjgC653VFAzD7y6Cg4qQuzkNIDQ-uEOqtC6pasOgn56P~w-6Pv3EoNIFkrJ0UKBtv8qgE4KmREWK7M8XUEfhu1z0HoJI~SMYw~vn3HvHWnBrUIi082dKGanqWYbKGcYt74L-9rdYLo7R-s2eWhxvveBz14X4ji5egAXMg__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
sudo tar -xzvf *.tar.gz
sudo rm *.tar.gz

# GRCh38 reference download
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz
tar -xzvf refdata-gex-GRCh38-2020-A.tar.gz
rm *.tar.gz

# Add Cellranger to PATH
export PATH=/opt/cellranger-7.0.0:$PATH
which cellranger
cellranger

# CellRanger Site Check
cellranger sitecheck > sitecheck.txt
less sitecheck.txt
ulimit -n 16000

# Verify installation
cellranger testrun --id=tiny

# Install bcl2fastq
sudo apt-get update
wget http://support.illumina.com/content/dam/illumina-support/documents/downloads/software/bcl2fastq/bcl2fastq2-v2.17.1.14-Linux-x86_64.rpm
sudo apt-get install alien --assume-yes
sudo alien bcl2fastq2-v2.17.1.14-Linux-x86_64.rpm
sudo dpkg -i bcl2fastq2_0v2.17.1.14-2_amd64.deb

# Make project dir
mkdir ~/yard/run_cellranger_count
cd ~/yard/run_cellranger_count
wget https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_1k_v3/pbmc_1k_v3_fastqs.tar
tar -xvf pbmc_1k_v3_fastqs.tar

# Pull github repo
wget https://github.com/mattfemia/scrnaseq-pipeline/archive/refs/heads/master.zip
sudo yum install unzip
unzip 

touch main.nf
