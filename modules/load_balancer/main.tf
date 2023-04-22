#############################################################
#############################################################
############ Code for the APPLICATION load balancer #########
#############################################################
#############################################################


resource "aws_security_group" "lb-sg" {
  name = "lb-Sg"
  vpc_id = var.vpc-id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTPS access"
    from_port = var.lb-port
    protocol = "tcp"
    to_port = var.lb-port
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# --------------------
# Creation of the ALB
# --------------------
resource "aws_lb" "app-lb" {
  name = "app-lb"
  internal = false
  load_balancer_type = "application"
  subnets = var.subnets_ids
  security_groups = [aws_security_group.lb-sg.id]
}

# ---------------------------------------
# Defining the target group for the ALB
# ---------------------------------------
resource "aws_lb_target_group" "lb-target-group" {
  name     = "load-balancer-target-group"
  port     = var.HTTP-server-port
  protocol = "HTTP"
  vpc_id   = var.vpc-id

  health_check {
    port     = var.HTTP-server-port
    protocol = "HTTP"
    enabled = true
    matcher = "200"
  }
}

# -----------------------------
# Attachment for the servers
# -----------------------------
resource "aws_lb_target_group_attachment" "lb-server-attachments" {
  count = length(var.instances_ids)

  target_group_arn = aws_lb_target_group.lb-target-group.arn
  target_id        = element(var.instances_ids, count.index)
  port             = var.HTTP-server-port
}

# -------------------------------------
# Defining the load balancer listenner
# -------------------------------------
resource "aws_lb_listener" "lb-listener"{
    load_balancer_arn = aws_lb.app-lb.arn
    protocol = "HTTPS"
    port = var.lb-port
    certificate_arn = "your certificate"

    default_action {
      target_group_arn = aws_lb_target_group.lb-target-group.arn
      type = "forward"
    }
}
