provider "aws" {
  region = "us-east-1"
}

### Backend ###
# S3
###############

terraform {
  backend "s3" {
    bucket = "cloudgeeks-backend121"
    key = "cloudgeeks.tfstate"
    region = "us-east-1"
  }
}


#####
# Vpc
#####

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

