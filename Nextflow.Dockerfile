FROM nextflow/nextflow:22.07.1-edge

RUN yum install wget -y && \
    yum install tar -y && \
    wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz && \
    tar xvf Python-3.9.10.tgz && \
    cd Python-3.9*/ && \
    ./configure --enable-optimizations && \
    make altinstall && \
    /usr/local/bin/python3.9 -m pip install --upgrade pip

WORKDIR /usr/src/app
COPY . .
RUN pip3 install -r requirements.txt

CMD ["nextflow", "run", "./main.nf"]
