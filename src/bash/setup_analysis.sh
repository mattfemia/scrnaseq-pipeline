#!/bin/bash

while getopts p: flag
do
    case "${flag}" in
        p) projectDir=${OPTARG};;
    esac
done
echo ${projectDir}/src/python/analysis.py
mkdir -p $projectDir/logs $projectDir/figures
mkdir -p $projectDir/data/analysis
touch $projectDir/logs/metadata.txt $projectDir/logs/runtime.txt