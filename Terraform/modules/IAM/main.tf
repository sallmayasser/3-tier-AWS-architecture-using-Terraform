resource "aws_iam_role" "backend_instance_role" {
  name = "backend-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend_ssm_access" {
  role       = aws_iam_role.backend_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_instance_profile" "backend_instance_profile" {
  name = "backend-instance-profile"
  role = aws_iam_role.backend_instance_role.name
}
