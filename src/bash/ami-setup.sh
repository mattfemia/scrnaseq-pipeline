#!/bin/bash

# java
sudo amazon-linux-extras install -y java-openjdk11

# Nextflow
curl -s https://get.nextflow.io | bash

# Install Docker
sudo yum update
sudo yum search docker
sudo yum info docker
sudo yum install docker
sudo usermod -a -G docker ec2-user
id ec2-user
newgrp docker

# Install docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service # Start docker
sudo systemctl stop docker.service #<-- stop the service
sudo systemctl status docker.service # Dont need to do this

# Add Docker to path
export PATH=$PATH:/usr/local/bin
echo "$PATH"
sudo find / -name "docker-compose" -ls

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
source ~/PROFILE_SCRIPT # Profile script should be the bashprofile
pip --version
