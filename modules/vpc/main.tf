

data "aws_eip" "by_filter" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_tags}-${var.project_name}-elasticIP"]
  }

}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name

  tags = {
    Name = "${var.env_tags}-${var.project_name}-vpc"
  }
}

resource "aws_vpc_dhcp_options" "dhcp-options" {
  
  domain_name          = ""
  domain_name_servers  = [ "AmazonProvidedDNS" ]
  ntp_servers          = []

  tags = {
    Name = "${var.env_tags}-${var.project_name}-dhcp-options"
  }
}
resource "aws_vpc_dhcp_options_association" "dhcp-options" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp-options.id
}

resource "aws_subnet" "public-subnet" {
  
  for_each = var.public_prefix
 
  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr"]
  vpc_id            = aws_vpc.main.id

  map_public_ip_on_launch = true # This makes the subnet public

  tags = {
    Name = "${var.env_tags}-${var.project_name}-public-subnet-${each.key}"
  }
 
}

resource "aws_subnet" "private-subnet" {
  for_each = var.private_prefix
 
  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr"]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-private-subnet-${each.key}"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-internet-gateway"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  
  allocation_id = data.aws_eip.by_filter.id 
  subnet_id     = aws_subnet.public-subnet["sub-1"].id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-NAT"
  }
}

resource "aws_default_route_table" "route_table_private" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-default-rtb"
  }
}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-public-rtb"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_tags}-${var.project_name}-private-rtb"
  }
}

resource "aws_route" "NAT_route" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gateway.id
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}
resource "aws_route_table_association" "rtb-public-subnet" {
  for_each = var.public_prefix
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet[each.key].id
}
resource "aws_route_table_association" "rtb-private-subnet" {
  for_each = var.private_prefix
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet[each.key].id
}

resource "aws_default_network_acl" "default-nacl" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
 
  tags = {
    Name = "${var.env_tags}-${var.project_name}-default-nacl"
  }
} 

resource "aws_network_acl" "public-nacl" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.env_tags}-${var.project_name}-public-nacl"
  }
}
resource "aws_network_acl" "private-nacl" {
  vpc_id = aws_vpc.main.id
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.env_tags}-${var.project_name}-private-nacl"
  }
}

resource "aws_network_acl_association" "public-nacl-association" {
  for_each = var.public_prefix

  network_acl_id = aws_network_acl.public-nacl.id
  subnet_id      = aws_subnet.public-subnet[each.key].id
}

resource "aws_network_acl_association" "private-nacl-association" {
  for_each = var.private_prefix

  network_acl_id = aws_network_acl.private-nacl.id
  subnet_id      = aws_subnet.private-subnet[each.key].id
  
}

