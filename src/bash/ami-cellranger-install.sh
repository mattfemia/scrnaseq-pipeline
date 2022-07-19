#!/bin/bash/env 

# Cellranger 7.0.0 download
cd /opt
curl -o cellranger-7.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.0.0.tar.gz?Expires=1658251696&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NTgyNTE2OTZ9fX1dfQ__&Signature=IqnRhY9DrUSdOwhQ4izLqRtq9E5dPes6uGwBZGzpQbc2oV4yUe2pHMnVXogPsb3V7zXyFop1nT3Yn5c4pGyU80oWLdUAdAZeTbuFgBCAn8zWy5MMX8iOHHBmm7n9eLd5JfOFzvqhZEZUyY4B7IPvEbMRrNF3iXP9MyYGTJdAkBPotXfl9KEMLouCrcjoKS5yn1FG5rnX5MRBipevx9TQLMWBf6iXcn4JHG39LcFMesxkm7~geT7iV1W-n77ovrMAL9lc1h4KguSKtwdzt8ai5tUykeHgtRWFbRMFbV3rj2f0oWoyiOmB0W~Yr4jaGawTHhiOWsZ1lC1dYZQoKnID9w__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
tar -xzvf cellranger-7.0.0.tar.gz

# GRCh38 reference download
curl -O https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz
tar -xzvf refdata-gex-GRCh38-2020-A.tar.gz

# Add Cellranger to PATH
export PATH=/opt/cellranger-7.0.0:$PATH
which cellranger
cellranger

# ----- #
# Site Check
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