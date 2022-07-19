#!/bin/bash/env 

# Cellranger 7.0.0 download
cd /opt
wget -O cellranger-7.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.0.0.tar.gz?Expires=1658295882&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci03LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NTgyOTU4ODJ9fX1dfQ__&Signature=nfrGaqnurk4Ra1~8Nd4US1pq8yKCRpqGJtyyOzd2xRhkOF2~XFiPslLgZ1F8Ow-1jqSrrGgoW-DlKOIJdkdL7hOz0IGAtKpz8Ei7MyPe4g0j~0Yw9QC3OPmheSz5p1kgAMOfJ-GvA5D7aJpfxTYI1Wp73cvTWtrQBLHmxAb7zuwuqBSHdnjgC653VFAzD7y6Cg4qQuzkNIDQ-uEOqtC6pasOgn56P~w-6Pv3EoNIFkrJ0UKBtv8qgE4KmREWK7M8XUEfhu1z0HoJI~SMYw~vn3HvHWnBrUIi082dKGanqWYbKGcYt74L-9rdYLo7R-s2eWhxvveBz14X4ji5egAXMg__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
tar -xzvf *.tar.gz
rm *.tar.gz

# GRCh38 reference download
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz
tar -xzvf refdata-gex-GRCh38-2020-A.tar.gz
rm *.tar.gz

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