variable "prefix" {
  type        = string
  description = "The name of our org, e.g., examplecom."
}
variable "environment" {
  type        = string
  description = "The name of our environment, e.g., development."
}
variable "vpc_cidr" {
  type        = list(string)
  description = "The CIDR of the VPC. e.g '10.0.0.0/16'"
}
variable "public_subnets" {
  type        = list(string)
  default     = []
  description = "The list of public subnets to populate. e.g 10.0.1.0/24"
}

variable "rgName" {
  type        = string
  description = "The resource group name"
  #   default     = "myTFResourceGroup"
}

variable "rgLocation" {
  type        = string
  description = "The resource group location."
  #   default     = "southeastasia"
}

variable "tags" {
  type = map(string)
}

variable "admin_username" {
  type        = string
  sensitive   = true
  description = "Username for the VM"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Password for the VM"
}