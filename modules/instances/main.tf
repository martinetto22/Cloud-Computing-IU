# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# ----------- -----MAIN WITH THE LOGIC OF THE MODULE: INSTANCES -------------------
# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------

# -----------------
# INSTANCIES
# -----------------

resource "aws_instance" "servers" {
  for_each = var.servers-map

  ami = var.ami-id
  instance_type = var.instance-type
  key_name = "NAME OF YOUR KEY!"
  subnet_id = each.value.subnet_id
  associate_public_ip_address = true
  private_ip = each.value.ip
  security_groups = [aws_security_group.server-sg.id]
  iam_instance_profile = var.instance-profile-name

  user_data = <<-EOF
            #!/bin/bash
            echo "This is ${each.value.name}" > index.html
            nohup busybox httpd -f -p ${var.HTTP-server-port} &
            EOF
  
  tags = {
    Name = each.value.name
    GroupName = "Production"
  }
}

# ---------------------------
# SECURITY GROUP del servidor
# ---------------------------

resource "aws_security_group" "server-sg" {
    name = "Servers-SG"
    vpc_id = var.vpc-id

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "HTTPS access"
      from_port = var.HTTP-server-port
      protocol = "tcp"
      to_port = var.HTTP-server-port
    }

    ingress {
      cidr_blocks = [ "172.0.0.0/16" ]
      description = "Ping"
      from_port = 8
      protocol = "icmp"
      to_port = 0
    }

    ingress {
      cidr_blocks = ["139.47.120.128/32"]
      description = "SSH access"
      from_port = var.SSH-server-port
      protocol = "tcp"
      to_port = var.SSH-server-port
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "all"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}