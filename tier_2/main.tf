
# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each   = var.private_subnets
  vpc_id     = data.aws_vpc.default.id
  cidr_block = cidrsubnet(data.aws_vpc.default.cidr_block, 8, each.value)

  tags = {
    Terraform = true
  }
}

# Security Groups
resource "aws_security_group" "cp_301_302_sg_prod_v2" {
  name        = "cp_301_302_sg_prod_v2"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "SSH Inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.250.0/24", "120.29.76.169/32"]
  }
  egress {
    description = "Global Outbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "cp_301_302_sg_prod_v2"
    Purpose = "For dev"
  }
}

resource "aws_instance" "cp_301_302_sg_prod_v2" {
  ami                         = "ami-06e85d4c3149db26a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnets["cp_301_302_sg_prod_v2"].id
  security_groups             = [aws_security_group.cp_301_302_sg_prod_v2.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.Cyrus.key_name
  #   iam_instance_profile        = "CloudWatchAgentServerPolicy"

  tags = {
    Name = "cp_301_302-prod"
  }
}

