provider "aws" {
    region = "us-east-1"
  
}

module "IAM" {
  source = "/mnt/c/Users/Avinash Kale/Desktop/Terraform/iam"
  
}

module "vpc_module" {
  source = "/mnt/c/Users/Avinash Kale/Desktop/Terraform/vpc_module"
  cidr_block_vpc = "10.0.0.0/16"
  cidr_block_webaz1 = "10.0.5.0/24"
  cidr_block_appaz1 = "10.0.4.0/24"
  cidr_block_dbaz1 = "10.0.3.0/24"
  cidr_block_webaz2 = "10.0.2.0/24"
  cidr_block_appaz2 = "10.0.1.0/24"
  cidr_block_dbaz2 = "10.0.6.0/24"
  availability_zone_az1 = "us-east-1a"
 availability_zone_az2 = "us-east-1b"
}
 
module "instance" {
  source = "/mnt/c/Users/Avinash Kale/Desktop/Terraform/instance_module"
vpc_id = module.vpc_module.vpc_id
security_private_instance = module.vpc_module.security_private_instance
internal_lb_sg = module.vpc_module.internal_lb_sg
security_database = module.vpc_module.security_database
subnet_id = module.vpc_module.subnet_id
subnet_app_az2 = module.vpc_module.subnet_app_az2
profile_name = module.IAM.profile_name
  
}

# module "database" {
#   source = "C:/Users/Avinash Kale/Desktop/Module/database"
#   database_grp_name = module.vpc_module.database_grp_name
#   security_database = module.vpc_module.security_database
# }

