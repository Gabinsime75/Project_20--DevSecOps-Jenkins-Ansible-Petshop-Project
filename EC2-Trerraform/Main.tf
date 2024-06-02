# IAM Role Creation: Creates an IAM role with a trust policy allowing EC2 instances to assume the role.
resource "aws_iam_role" "example_role" {
  name               = "Jenkins-terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Attaches the AdministratorAccess policy to the IAM role.
resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# Creates an instance profile that can be attached to an EC2 instance.
resource "aws_iam_instance_profile" "example_profile" {
  name = "Jenkins-terraform"
  role = aws_iam_role.example_role.name
}


resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security Group"
  vpc_id      = "vpc-0d4e96866b290d61d"
  description = "Open 22,443,80,8080,9000, 3000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}

resource "aws_instance" "Jenkins" {
  ami                         = "ami-0cf2b4e024cdb6960"
  instance_type               = "t2.large"
  key_name                    = "Oregon_kp"
  vpc_security_group_ids      = [aws_security_group.Jenkins-sg.id]
  user_data                   = templatefile("./install_jenkins.sh", {})
  iam_instance_profile        = aws_iam_instance_profile.example_profile.name
  associate_public_ip_address = true
  subnet_id                   = "subnet-014263cc1ed7db0e8"


  tags = {
    Name = "Jenkins"
  }

  root_block_device {
    volume_size = 30
  }
}
