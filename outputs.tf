output "vpc_id" {
  description = "The ID of the VPC"
  value = "${aws_vpc.main.id}"
}

output "public_subnet_id" {
  description = "List of IDs of public subnets"
  value = values(aws_subnet.public-subnet).*.id
}

output "private_subnet_id" {
  description = "List of IDs of private subnets"
  value = values(aws_subnet.private-subnet).*.id
}

output "security_group_id" {
  description = "The ID of the security group created"
  value = "${aws_security_group.main-sg.id}"
}

output "instance_id" {
  description = "The ID of the EC2"
  value = "${aws_instance.instance.id}"
}


