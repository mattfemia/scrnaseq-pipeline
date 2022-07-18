#!/bin/bash/env

terraform init # Initialize tf env in working dir
terraform fmt # Use tf to correct formatting errors in .tf files
terraform apply -auto-approve -compact-warnings # Deploy infrastructure
terraform show # Inspect current state of tf-init resources
terraform destroy # Destroy resources managed by tf