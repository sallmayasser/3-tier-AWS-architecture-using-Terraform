aws-region = "us-east-1"
vpc-cidr   = "10.0.0.0/16"

subnets = [
  {
    name       = "public-subnet-1"
    cidr_block = "10.0.0.0/24"
    type       = "public"
    az         = "a"
  },
  {
    name       = "public-subnet-2"
    cidr_block = "10.0.1.0/24"
    type       = "public"
    az         = "b"

  },
  {

    name       = "private-subnet-1"
    cidr_block = "10.0.2.0/24"
    type       = "private"
    az         = "a"

  },
  {
    name       = "private-subnet-2"
    cidr_block = "10.0.3.0/24"
    type       = "private"
    az         = "b"

  },
  {

    name       = "db-subnet-1"
    cidr_block = "10.0.4.0/24"
    type       = "private"
    az         = "a"

  },
  {
    name       = "db-subnet-2"
    cidr_block = "10.0.5.0/24"
    type       = "private"
    az         = "b"

  }
]
public_key_path = "./mykey.pub"
instance-type   = "t2.micro"
