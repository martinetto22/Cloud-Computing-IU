resource "aws_security_group" "nlb-sg" {
  count = length(var.vpc-id)

  name = "nlb-Sg"
  vpc_id = var.vpc-id[count.index]

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP access"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# --------------------
# Creation of the NLB
# --------------------

resource "aws_lb" "network-lb" {
  count = length(var.subnets-id)

  name               = "nlb-${count.index}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.subnets-id[count.index]]
}

resource "aws_lb_target_group" "nlb-target-group" {
  count = length(var.vpc-id)

  name     = "n-load-balancer-tg-${count.index}"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc-id[count.index]

  health_check {
    port     = 80
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# -------------------------------------
# Defining the load balancer listenner
# -------------------------------------
resource "aws_lb_listener" "lb-listener"{
  count = length(var.subnets-id)

  load_balancer_arn = aws_lb.network-lb[count.index].arn
  protocol = "TCP"
  #port = var.ssh-port
  port = 80

  default_action {
    target_group_arn = aws_lb_target_group.nlb-target-group[count.index].arn
    type = "forward"
  }


}
