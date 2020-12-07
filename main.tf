terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.20.0"
    }
  }
}

# AWS Educate er berre i N.Virginia
provider "aws" {
  region = "us-east-1"
}

# Lag nøkkel
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096

}
# Nødvendig for å logge inn med SSH på EC2
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_ec2_access
  public_key = tls_private_key.key.public_key_openssh
}

# Hent siste Amazon Linux image
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# Sjølvaste EC2 instansen
resource "aws_instance" "webserver" {
  count         = var.ec2_count
  instance_type = var.ec2_type
  ami           = data.aws_ami.amazon_linux.id
  key_name      = aws_key_pair.generated_key.key_name
  # Sona må vere lik mellom ELB <-> EC2-instansane!
  availability_zone = "us-east-1a"
  security_groups = [
    aws_security_group.sg_web_mgmt.name,
    aws_security_group.sg_mgmt_ping.name,
  aws_security_group.sg_all_http.name]
  tags = {
    TagTest = "WebKnagg"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.key.private_key_pem
    host        = self.public_ip
  }

  # Bruker user data til å gjere det samme
  provisioner "file" {
    source      = "./setup.sh"
    destination = "/home/ec2-user/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x setup.sh",
      "./setup.sh"
    ]

  }
}

# I følge Amazon må ELB-ar ha randomiserte namn
# fordi dette blir ein del av domenenamnet
resource "random_string" "lb_id" {
  length  = 4
  special = false
}

resource "aws_elb" "lb_web" {
  name               = trimsuffix(substr(replace(join("-", ["lb", random_string.lb_id.result, var.id_prefix, var.runtime_prefix]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  availability_zones = ["us-east-1a"]

  listener {
    lb_protocol       = "HTTP"
    lb_port           = 80
    instance_port     = 80
    instance_protocol = "HTTP"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 2
    target              = "HTTP:80/"
    interval            = 5
  }
  instances = aws_instance.webserver.*.id

}

resource "aws_security_group" "sg_mgmt_ping" {
  name = "sg_mgmt_ping"
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp" #PING
    cidr_blocks = var.sg_mgmt_allow_ips
  }
}

resource "aws_security_group" "sg_all_http" {
  name = "sg_all_http"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" # HTTP
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tillat trafikk frå alleplassar ut 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_web_mgmt" {
  name = "sg_web_mgmt"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" # SSH
    cidr_blocks = var.sg_mgmt_allow_ips
  }
}