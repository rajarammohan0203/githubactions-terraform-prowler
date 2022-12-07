provider "aws" {
  region = "us-east-1"
}

### Backend ###
# S3
###############

terraform {
  backend "s3" {
    bucket = "cloudgeeks-backend12"
    key = "cloudgeeks.tfstate"
    region = "us-east-1"
  }
}


#####
# Vpc
#####


