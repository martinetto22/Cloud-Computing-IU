# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# ---------------SECONDARY WITH THE LOGIC OF THE MODULE: INSTANCES ----------------
# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------

##################################################
############### LAUNCH TEMPLATE ##################
##################################################

resource "aws_launch_template" "launch-template" {
  count = length(var.vpc-ids)

  name = "calculation-template-${count.index}"
  image_id = var.ami-id
  instance_type = "t2.micro"
  iam_instance_profile {
    arn = var.arn-instance-profile
  }
  key_name = "NAME OF YOUR KEY"
  vpc_security_group_ids = [aws_security_group.server-sg[count.index].id]

}

# -----------------------
# Servers SECURITY GROUP
# -----------------------

resource "aws_security_group" "server-sg" {
  count = length(var.vpc-ids)

  name = "SG-vpc-${count.index}"
  vpc_id = var.vpc-ids[count.index]

  ingress {
    cidr_blocks = [var.from-main-vpc]
    description = "SSH access"
    from_port = var.SSH-server-port
    protocol = "tcp"
    to_port = var.SSH-server-port
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for SSM"
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "from load balancer to instance"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress {
    cidr_blocks = [ "172.0.0.0/16" ]
    description = "Ping"
    from_port = 8
    protocol = "icmp"
    to_port = 0
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#######################################################
############# ENDPOINTS FOR SSM CONNECTION ############
#######################################################

resource "aws_vpc_endpoint" "ssm" {
  count = length(var.vpc-ids)

  private_dns_enabled = true
  vpc_id       = var.vpc-ids[count.index]
  service_name = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ var.private-subnets[count.index] ]
  security_group_ids = [ aws_security_group.server-sg[count.index].id ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = length(var.vpc-ids)

  private_dns_enabled = true
  vpc_id       = var.vpc-ids[count.index]
  service_name = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ var.private-subnets[count.index] ]
  security_group_ids = [ aws_security_group.server-sg[count.index].id ]
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = length(var.vpc-ids)

  private_dns_enabled = true
  vpc_id       = var.vpc-ids[count.index]
  service_name = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ var.private-subnets[count.index] ]
  security_group_ids = [ aws_security_group.server-sg[count.index].id ]
}