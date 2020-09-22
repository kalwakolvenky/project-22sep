provider "aws" {
#     access_key = "${var.aws_access_key}"
#     secret_key = "${var.aws_secret_key}"
    region = "us-east-1"
}

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"

    tags  = {
        Name = "${var.vpc_name}"
    }

}

resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.subnet_cidr}"
    availability_zone = "us-east-1a"

    tags = {
        Name = "${var.subnet_name}"
    }

}

# resource "aws_vpc" "default1" {
#     cidr_block = "${var.vpc_cidr1}"

#     tags  = {
#         Name = "${var.vpc_name1}"
#     }

# }

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "${var.IGW}"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.foo.id
#   }

  tags = {
    Name = "${var.route}"
  }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.subnet1-public.id}"
    route_table_id = "${aws_route_table.r.id}"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.s-g}"
  }
}

resource "aws_instance" "web-1" {
    #ami = "${data.aws_ami.my_ami.id}"
    ami = "ami-0d857ff0f5fc4e03b"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "aws"
    subnet_id = "${aws_subnet.subnet1-public.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
    associate_public_ip_address = true	
    tags = {
        Name = "Server-1"
        Env = "Prod"
        Owner = "Venky"
	CostCenter = "ABCD"
    }
}

terraform {
  backend "s3" {
    bucket = "devops-backend"
    key    = "myterraform.tfstate"
    region = "us-east-1"
  }
}

# resource "aws_subnet" "subnet2-public" {
#     vpc_id = "${aws_vpc.default1.id}"
#     cidr_block = "${var.subnet_cidr1}"
#     availability_zone = "us-east-1b"

#     tags = {
#         Name = "${var.subnet_name1}"
#     }

# }
