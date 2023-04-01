#################################################################
#################################################################
### Defining System Manager to have direct access to instances ##
#################################################################
#################################################################

# ---------------------------------------------------------------
# Instance profile where we put the accepted policies for the
# ssm agent
# ---------------------------------------------------------------
resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
    name = "ec2_profile"
    role = aws_iam_role.dev-resources-iam-role.name
}

# -------------------------------------------------------
# Role to specify which services can assume the policies
# -------------------------------------------------------
resource "aws_iam_role" "dev-resources-iam-role" {
    name        = "dev-ssm-role"
    description = "The role for the developer resources EC2"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {"Service": ["ec2.amazonaws.com", "ssm.amazonaws.com"]},
            "Action": "sts:AssumeRole"
        }
    }
    EOF
    tags = {
    stack = "test"
    }
}

# -----------------------------------------------
# Attachment of the policies defined to the role
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
    role       = aws_iam_role.dev-resources-iam-role.name
    policy_arn = aws_iam_policy.policy.arn
}

# ------------------
# Policy definition
# ------------------
resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {

  statement {
    effect    = "Allow"
    actions   = ["ssm:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ds:CreateComputer", 
                "ds:DescribeDirectories"]
    resources = ["*"]
  }

    statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }
}