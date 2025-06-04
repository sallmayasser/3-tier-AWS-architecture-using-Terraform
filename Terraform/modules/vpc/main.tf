# -------------------------------------------
# |                                          | 
# |               create vpc                 |
# |                                          |
# -------------------------------------------

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "myVpc"
  }
}

# -------------------------------------------
# |                                          | 
# |              create subnets              |
# |                                          |
# -------------------------------------------

resource "aws_subnet" "subnets" {
  for_each                = { for subnet in var.subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  availability_zone       = "${var.region}${each.value.az}"
  tags                    = { "Name" = each.value.name }
}

# -------------------------------------------
# |                                          | 
# |               create IGW                 |
# |                                          |
# -------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "IGW"
  }
}
# -------------------------------------------
# |                                          | 
# |          Public Routing Tables           |
# |                                          |
# -------------------------------------------
resource "aws_route_table" "pub-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-RT"
  }
}

# -------------------------------------------
# |                                          | 
# |          Public Table association        |
# |                                          |
# -------------------------------------------
resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.subnets["public-subnet-1"].id
  route_table_id = aws_route_table.pub-table.id
}

resource "aws_route_table_association" "pub-b" {
  subnet_id      = aws_subnet.subnets["public-subnet-2"].id
  route_table_id = aws_route_table.pub-table.id
}

# -------------------------------------------
# |                                          | 
# |          create elastic ip               |
# |                                          |
# -------------------------------------------
resource "aws_eip" "my-eip" {
  domain = "vpc"
  tags = {
    Name = "elastic-ip"
  }
}
# -------------------------------------------
# |                                          | 
# |             create nat-GW                |
# |                                          |
# -------------------------------------------
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.subnets["public-subnet-2"].id

  tags = {
    Name = "my-NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}
# -------------------------------------------
# |                                          | 
# |          Private Routing Table           |
# |                                          |
# -------------------------------------------
resource "aws_route_table" "priv-table" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat.id
  }
  tags = {
    Name = "private-RT"
  }
}

# -------------------------------------------
# |                                          | 
# |         Private Table association        |
# |                                          |
# -------------------------------------------
resource "aws_route_table_association" "priv-a" {
  subnet_id      = aws_subnet.subnets["private-subnet-1"].id
  route_table_id = aws_route_table.priv-table.id
}
resource "aws_route_table_association" "priv-b" {
  subnet_id      = aws_subnet.subnets["private-subnet-2"].id
  route_table_id = aws_route_table.priv-table.id
}
resource "aws_route_table_association" "db-a" {
  subnet_id      = aws_subnet.subnets["db-subnet-1"].id
  route_table_id = aws_route_table.priv-table.id
}
resource "aws_route_table_association" "db-b" {
  subnet_id      = aws_subnet.subnets["db-subnet-2"].id
  route_table_id = aws_route_table.priv-table.id
}
