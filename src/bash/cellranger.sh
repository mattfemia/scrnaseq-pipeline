#!/bin/bash 

# Cellranger

## Setup
mkdir yard
cd /mnt/home/user.name/yard
mkdir apps
cd apps

## Download
sudo wget -O cellranger-6.0.2.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.0.2.tar.gz?Expires=1625580741&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjAuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MjU1ODA3NDF9fX1dfQ__&Signature=BK1vZv-NxoL7GoD5QQReBi1eBiV1ItN5OJuQzy9KIaT5458hTEh1-RbtHnxqRj1cU9XkzX~i3n9SdcokA11wNkpag4mDQ9ucApqhGScDi5i9qhHuIwKXZnu7ys2fonmWgJIwKcQvxgbo6oKynpieA4RBmZmvb3t1LNdbYQRkPRSfuVrtWk2oLmHL7WtDtbtU0p3qMK270oitAbZeWLIkUO8mjyZOenrQ1EDPTgVInBqNOL-FLlXnryWp6rzJHxdm-atyOnIXik4DUyRpsGNX6FyvSCD9kyatxYdp4jbs8CRHE-JZjddPXSPRNIIUtanT02o1hAom5RJzrcD3TuyDyw__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
ls -1
sudo chmod 755 cellranger-6.0.2.tar.gz
tar -xzvf cellranger-6.0.2.tar.gz
# tar -zxvf cellranger-3.1.0.tar.gz

## Add CR to PATH
cd cellranger-6.0.2.tar.gz
pwd
export PATH=/data/cellranger-6.0.1:$PATH
# export PATH=/mnt/home/user.name/yard/apps/cellranger-3.1.0:$PATH
which cellranger

## Sitecheck
cellranger sitecheck > sitecheck.txt
less sitecheck.txt
ulimit -n 16000 ## Only if 'open files' in less is less than 16000
cellranger testrun --id=check_install # Takes ~ 5min


cellranger mkfastq --id=tinybcl \
                    --run=/home/ec2-user/data/tinybcl \
                    --csv=cellranger-tiny-bcl-simple-1.2.0.csv



## Setup cellranger mkfastq
mkdir ~/yard/run_cellranger_mkfastq
cd ~/yard/run_cellranger_mkfastq
cellranger mkfastq --help

wget https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-1.2.0.tar.gz
wget https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-simple-1.2.0.csv
tar -zxvf cellranger-tiny-bcl-1.2.0.tar.gz
cat cellranger-tiny-bcl-simple-1.2.0.csv
tree -L 2 cellranger-tiny-bcl-1.2.0/
ls -altR cellranger-tiny-bcl-1.2.0/


## Run mkfastq
cellranger mkfastq --id=tutorial_walk_through \
--run=/mnt/home/user.name/yard/run_cellrnager_mkfastq/cellranger-tiny-bcl-1.2.0 \
--csv=/mnt/home/user.name/yard/run_cellrnager_mkfastq/cellranger-tiny-bcl-simple-1.2.0.csv

cd /mnt/home/user.name/yard/run_cellrnager_mkfastq/tutorial_walk_through/outs/fastq_path
ls -1
ls -1 H35KCBCXY/test_sample


## Get FASTQ and Ref data
mkdir ~/yard/run_cellranger_count
cd ~/yard/run_cellranger_count

wget https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_1k_v3/pbmc_1k_v3_fastqs.tar
tar -xvf pbmc_1k_v3_fastqs.tar
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-cellranger-GRCh38-3.0.0.tar.gz
tar -zxvf refdata-cellranger-GRCh38-3.0.0.tar.gz

## Run count command
cellranger count --help

cellranger count --id=run_count_1kpbmcs \
--fastqs=/mnt/home/user.name/yard/run_cellranger_count/pbmc_1k_v3_fastqs \
--sample=pbmc_1k_v3 \
--transcriptome=/mnt/home/user.name/yard/run_cellranger_count/refdata-cellranger-GRCh38-3.0.0

ls -1 run_count_1kpbmcs/outs

cellranger count --id=run_count_1kpbmcs \
--fastqs=/data/raw/pbmc_1k_v3_fastqs \
--sample=pbmc \
--transcriptome=/data/refdata-cellranger-GRCh38-3.0.0



## Run aggr function
cellranger aggr --help
mkdir ~/yard/run_cellranger_aggr
cd ~/yard/run_cellranger_aggr
wget https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_1k_v3/pbmc_1k_v3_molecule_info.h5
wget https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_10k_v3/pbmc_10k_v3_molecule_info.h5
pwd
vim pbmc_aggr.csv

## Copy and paste into vim (uncomment)
# library_id,molecule_h5
# 1k_pbmcs,/mnt/home/user.name/yard/run_cellranger_aggr/pbmc_1k_v3_molecule_info.h5
# 10k_pbmcs,/mnt/home/user.name/yard/run_cellranger_aggr/pbmc_10k_v3_molecule_info.h5

cellranger aggr --id=1k_10K_pbmc_aggr --csv=pbmc_aggr.csv
ls -1 1k_10K_pbmc_aggr/outs/
