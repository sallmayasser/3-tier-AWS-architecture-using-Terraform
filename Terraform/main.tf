#  ------------------------------------------
# |                                          | 
# |               Create VPC                 |
# |                                          |
#  ------------------------------------------

module "vpc" {
  source   = "./modules/vpc"
  region   = var.aws-region
  vpc-cidr = var.vpc-cidr
  subnets  = var.subnets
}

#  ------------------------------------------
# |                                          | 
# |         create Security Groups           |
# |                                          |
#  ------------------------------------------
# ///////////////////// External Alb security group ///////////////////// 
module "pub-alb-sg" {
  source      = "./modules/security-groups"
  name        = "External-alb-SG"
  description = "application loadbalancer Security Group"
  vpc_id      = module.vpc.vpc-id

  ingress_rules = {
    http = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80

    }
  }

}
# ////////////////////////// Public Secuity Group ////////////////////////
module "public-sg" {
  source      = "./modules/security-groups"
  name        = "public-SG"
  description = "Public Security Group"
  vpc_id      = module.vpc.vpc-id
  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.pub-alb-sg.sg_id
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
    ssh = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 22
      ip_protocol                  = "tcp"
      to_port                      = 22
    }
  }

  tags = {
    Name = "public-SG"
  }
}
# ///////////////////// Internal Alb security group ///////////////////// 
module "priv-alb-sg" {
  source      = "./modules/security-groups"
  name        = "Internal-alb-SG"
  description = "application loadbalancer Security Group"
  vpc_id      = module.vpc.vpc-id

  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.public-sg.sg_id
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80

    }
  }

}
# ////////////////////////// Private Secuity Group ////////////////////////
module "private-sg" {
  source      = "./modules/security-groups"
  name        = "private-SG"
  description = "private Security Group"
  vpc_id      = module.vpc.vpc-id
  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.priv-alb-sg.sg_id
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
    ssh = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.public-sg.sg_id
      from_port                    = 22
      ip_protocol                  = "tcp"
      to_port                      = 22
    }
  }
  tags = {
    Name = "private-SG"
  }
}
# ////////////////////////// Databases security groups ///////////////
module "db-sg" {
  source      = "./modules/security-groups"
  name        = "db-SG"
  description = "databases Security Group"
  vpc_id      = module.vpc.vpc-id

  ingress_rules = {
    mysql = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.private-sg.sg_id
      from_port                    = 27017 # MongoDb port 
      ip_protocol                  = "tcp"
      to_port                      = 27017

    }
  }

}
#  ------------------------------------------
# |                                          | 
# |              create ASG                  |
# |                                          |
#  ------------------------------------------

# ////////////////////// Key Pair /////////////////////////
resource "aws_key_pair" "my_key" {
  key_name   = "mykey"
  public_key = file(var.public_key_path)
}
# ///////////////////////// User Data /////////////////////////
data "template_file" "frontend_user_data" {
  template = file("./modules/ASG/UserData/frontend.sh.tpl")
  vars = {
    backend_alb_dns = module.priv-alb.alb-dns
  }
}

data "template_file" "backend_user_data" {
  template = file("./modules/ASG/UserData/backend.sh.tpl")
  vars = {
    ssm_param_name = module.databases.ssm_param_name
  }
}
# ////////////////////////// FrontEnd ASG //////////////////////////
module "frontend-asg" {
  source             = "./modules/ASG"
  template-name      = "frontend-template"
  instance-type      = var.instance-type
  my-key             = aws_key_pair.my_key.key_name
  user-data          = base64encode(data.template_file.frontend_user_data.rendered)
  security-group-ids = [module.public-sg.sg_id]
  ASG-name           = "frontend-asg"
  max_size           = 3
  min_size           = 1
  desired_capacity   = 2
  vpc-zone-ids       = [module.vpc.public-subnet-id-1, module.vpc.public-subnet-id-2]
  target-grps-arn    = [module.pub-alb.target_group_arn]
  instance-name      = "frontend-instance"
  depends_on         = [module.priv-alb]
}
# ///////////////////////////// BackEnd ASG //////////////////////////
module "backend-asg" {
  source             = "./modules/ASG"
  template-name      = "backend-template"
  instance-type      = var.instance-type
  my-key             = aws_key_pair.my_key.key_name
  user-data          = base64encode(data.template_file.backend_user_data.rendered)
  security-group-ids = [module.private-sg.sg_id]
  ASG-name           = "backend-asg"
  max_size           = 3
  min_size           = 1
  desired_capacity   = 2
  vpc-zone-ids       = [module.vpc.private-subnet-id-1, module.vpc.private-subnet-id-2]
  target-grps-arn    = [module.priv-alb.target_group_arn]
  instance-name      = "backend-instance"
  depends_on         = [module.databases]
}

#  ------------------------------------------
# |                                          | 
# |              create ALB                  |
# |                                          |
#  ------------------------------------------

# ///////////////////// External Alb ///////////////////// 
module "pub-alb" {
  source             = "./modules/ALB"
  alb-name           = "External-alb"
  isInternal         = false
  security-group-ids = [module.pub-alb-sg.sg_id]
  subnet-ids         = [module.vpc.public-subnet-id-1, module.vpc.public-subnet-id-2]
  vpc-id             = module.vpc.vpc-id
  target-gp-name     = "frontend-target-group"

  health_check_config = {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

}
# ///////////////////// Internal Alb ///////////////////// 
module "priv-alb" {
  source             = "./modules/ALB"
  alb-name           = "Internal-alb"
  isInternal         = true
  security-group-ids = [module.priv-alb-sg.sg_id]
  subnet-ids         = [module.vpc.public-subnet-id-1, module.vpc.public-subnet-id-2]
  vpc-id             = module.vpc.vpc-id
  target-gp-name     = "backend-target-group"

  health_check_config = {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

#  ------------------------------------------
# |                                          | 
# |             create Databases             |
# |                                          |
#  ------------------------------------------

#////////////////////// create the  databases /////////////////////
locals {
  azs = distinct([
    for subnet in var.subnets : "${var.aws-region}${subnet.az}"
  ])
}

module "databases" {
  source      = "./modules/database"
  subnet-ids  = [module.vpc.db-subnet-id-1, module.vpc.db-subnet-id-2]
  sg-id-list  = [module.db-sg.sg_id]
  db_username = var.db_username
  db_password = var.db_password
  azs         = local.azs
}
