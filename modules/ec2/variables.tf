variable "region" {
  default = ""
}

variable "project_name" {
   description = "Prefix used for all resources names"
   default = ""
   type = string
}

variable "env_name" {
 description = "Prefix used for all environment names"
 default = ""
 type = string
}
variable "env_tags" {
 description = "Prefix used for all environment tags"
 default = ""
 type = string
}

variable "public_prefix" {
   description = "A map of public subnets inside the VPC"
   type = map
   default = {}
}

variable "private_prefix" {
   description = "A map of private subnets inside the VPC"
   type = map
   default = {}
}

variable "security_group_id" {}

variable "instance_type" {
   description = "Instance type to use for the instance."
   type = string
}

variable "subnet_id" {}

/*variable "ssh_key_name" {}

variable "private_key_path" {}*/