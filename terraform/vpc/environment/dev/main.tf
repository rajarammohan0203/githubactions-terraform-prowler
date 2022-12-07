provider "aws" {
  region = "us-east-1"
}

### Backend ###
# S3
###############

terraform {
  backend "s3" {
    bucket = "cloudgeeks-backend1"
    key = "cloudgeeks.tfstate"
    region = "us-east-1"
  }
}


#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.11.0.0/16"
  vpc-public-subnet-cidr              = ["10.11.1.0/24","10.11.2.0/24"]
  vpc-private-subnet-cidr             = ["10.11.4.0/24","10.11.5.0/24"]
  vpc-database_subnets-cidr           = ["10.11.7.0/24", "10.11.8.0/24"]
}

module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "wordpress"
  tcp_ports           = "22,80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "wordpress"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "wordpress-Ref"
  tcp_ports               = "22,80,443"
  ref_security_groups_ids = [module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default]
  security_group_name     = "wordpress-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "wordpress-eip" {
  source = "../../modules/eip/wordpress"
  name                         = "wordpress"
  instance                     = module.ec2-wordpress.id[0]
}

module "ec2-keypair" {
  source = "../../modules/aws-ec2-keypair"
  key-name      = "wordpress"
  public-key    = file("../../modules/secrets/wordpress.pub")
}

module "ec2-wordpress" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "wordpress"
  key_name                      = "wordpress"
  user_data                     = file("../../modules/aws-ec2/user-data/wordpress/user-data.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 40
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}




