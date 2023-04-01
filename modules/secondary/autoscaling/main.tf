###################################################################
###################################################################
############ Auto scaling for the calculation servers##############
###################################################################
###################################################################


# With aws_placement_group strategy set to "partition" the capacity
# reservation is not possible


resource "aws_autoscaling_group" "asg-calculation-instances" {
  count = length(var.subnets-id)

  name                      = "Autoscaling-Calculation-Instances-${count.index}"
  max_size                  = 4
  min_size                  = 3
  desired_capacity          = 3
  force_delete              = true
  vpc_zone_identifier       = [var.subnets-id[count.index]]
  launch_template {
    id = var.launch-template-id[count.index]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers]
  }

  target_group_arns = [var.nlb-arn[count.index]]
}
