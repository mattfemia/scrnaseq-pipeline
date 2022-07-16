FROM python:3.9.13

WORKDIR /usr/src/app

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
RUN apt-get install -y openjdk-11-jdk ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f
ENV JAVA_HOME ~/usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME

# Install Nextflow
RUN cd /usr/local/bin && \
    curl -s https://get.nextflow.io | bash

COPY . .

RUN pip3 install -r requirements.txt

CMD ["nextflow", "run", "./main.nf"]
