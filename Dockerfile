
FROM python:3.7.11-stretch

# Install bash tools and gcc bins for Python dependencies
RUN apt-get update && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get install -y build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get update && \
    apt-get upgrade -y 

# Install OpenJDK and add to PATH
# **Dependency for Nextflow
RUN set -eux; \
    curl -Lso /tmp/openjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Linux_jdk-10.0.2%2B13.tar.gz; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz; \
    jdir=$(dirname $(dirname $(find /opt/java/openjdk -name javac))); \
    mv ${jdir}/* /opt/java/openjdk; \
    rm -rf ${jdir} /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

# Install Nextflow
RUN cd /usr/local/bin && \
    curl -s https://get.nextflow.io | bash


# Install bcl2fastq v2.20 --> *CellRanger dependency for running mkfastq command on bcl files
# -- get from Illumina

# Install Cellranger-6.0.1 -- 
# This link is non-expiring/non-tokenized as opposed to official link at 10XGenomics website
RUN cd /opt/ && \
	wget https://galaxyweb.umassmed.edu/pub/software/cellranger-6.0.1.tar.gz && \ 
    tar -xzvf cellranger-6.0.1.tar.gz && \
    rm -rf cellranger-6.0.1.tar.gz

# Add CellRanger to PATH
ENV PATH /opt/cellranger-6.0.1:$PATH

# Add GRCh38 Reference - 3.0.0
RUN wget -O /opt/vdj-GRCh38-2020.tar.gz https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz && \
    tar -xzvf /opt/vdj-GRCh38-2020.tar.gz && \
    rm -rf /opt/vdj-GRCh38-2020.tar.gz

# **OPTIONAL Add Test Data
RUN wget -O /opt/fastq/pbmc_1k_v3_fastqs.tar https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_1k_v3/pbmc_1k_v3_fastqs.tar && \
    tar -xvf /opt/pbmc_1k_v3_fastqs.tar && \
    rm -rf /opt/pbmc_1k_v3_fastqs.tar

# Move files into /opt dir
COPY . /opt/

# Install Python dependencies for Scanpy analysis
RUN pip install pandas==1.2.5 scanpy==1.7.2 anndata==0.7.6 python-igraph==0.7.1.post6 leidenalg==0.7.0

# Test CellRanger with sitecheck
RUN cellranger sitecheck > sitecheck.txt