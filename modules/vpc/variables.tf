variable "region" {
  default = ""
  type = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  default = "10.0.0.0/16"
  type = string
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