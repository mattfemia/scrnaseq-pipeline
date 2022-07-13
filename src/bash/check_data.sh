#!/bin/bash/env

while getopts p: flag
do
    case "${flag}" in
        p) projectDir=${OPTARG};;
    esac
done

if [ -d ${projectDir}/data ]; then
   echo "Data Directory Exists"
else
   mkdir ${projectDir}/data
fi

if [ -z "$(ls -A ${projectDir}/data)" ]; then
   wget -qO- "https://cf.10xgenomics.com/samples/cell-exp/4.0.0/Parent_NGSC3_DI_PBMC/Parent_NGSC3_DI_PBMC_raw_feature_bc_matrix.tar.gz"  | tar xvz -C ${projectDir}/data
else
   echo "Not Empty"
fi
