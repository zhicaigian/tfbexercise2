rgName     = "myTFResourceGroup"
rgLocation = "southeastasia"

tags = {
  environment = "Terraform Getting Started"
  team        = "DevOps"
}

prefix          = "tfbex"
environment     = "development"
vpc_cidr        = ["10.0.0.0/16"]
public_subnets  = ["10.0.1.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]