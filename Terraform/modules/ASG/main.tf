# //////////////////////// AMI data source //////////////////////////
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}
# //////////////////////// Launch Template //////////////////////////
resource "aws_launch_template" "my-launch-template" {
  name_prefix            = "${var.template-name}-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  key_name               = var.my-key
  user_data              = var.user-data
  vpc_security_group_ids = var.security-group-ids

  lifecycle {
    create_before_destroy = true
  }
}
# ///////////////////////// Autoscaling group creation ///////////////////////
resource "aws_autoscaling_group" "my-ASG" {
  name                      = "${var.ASG-name}-ASG"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-ids
  target_group_arns         = var.target-grps-arn

  launch_template {
    id      = aws_launch_template.my-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.instance-name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "15m"
  }

}
