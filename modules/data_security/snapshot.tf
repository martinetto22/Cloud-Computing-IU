#################################################################################################################
################################################# SNAPSHOTS #####################################################
# https://www.cloudthat.com/resources/blog/create-aws-lifecycle-policy-using-terraform-for-taking-ebs-snapshots #
############## https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dlm-access-control.html ######################
#################################################################################################################


resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "dlm.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "dlm-lifecycle-policy"
  role = "${aws_iam_role.dlm_lifecycle_role.id}"

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateTags"
        ],
        "Resource": "arn:aws:ec2:*::snapshot/*"
      }
    ]
  })
}

resource "aws_dlm_lifecycle_policy" "test_lifecyclerole" {
  description        = "DLM lifecycle policy"
  execution_role_arn = "${aws_iam_role.dlm_lifecycle_role.arn}"
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}
