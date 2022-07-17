terraform {
  backend "remote" {
    organization = ""
    workspaces {
      name = "scrna-pipeline"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  # shared_config_files      = [""]
  # shared_credentials_files = [""]
  # profile                  = ""
  region                   = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-02f3416038bdb17fb"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}