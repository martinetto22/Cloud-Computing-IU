####################################################################################################################
############################################# BUCK UPS POLICIES ####################################################
# https://shadabambat1.medium.com/automatically-backup-your-ec2-instances-using-aws-backups-terraform-c06d15e2a9c2 #
####################################################################################################################
/* Assume Role Policy for Backups */
data "aws_iam_policy_document" "example-aws-backup-service-assume-role-policy-doc" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

/* The policies that allow the backup service to take backups and restores */
data "aws_iam_policy" "aws-backup-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "aws-restore-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

data "aws_caller_identity" "current_account" {}

/* Needed to allow the backup service to restore from a snapshot to an EC2 instance
 See https://stackoverflow.com/questions/61802628/aws-backup-missing-permission-iampassrole */
data "aws_iam_policy_document" "example-pass-role-policy-doc" {
  statement {
    sid       = "ExamplePassRole"
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:role/*"]
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "example-aws-backup-service-role" {
  name               = "ExampleAWSBackupServiceRole"
  description        = "Allows the AWS Backup Service to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.example-aws-backup-service-assume-role-policy-doc.json

  tags = {
    Role    = "iam"
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "example-aws-restore-backup-service-role" {
  name               = "ExampleAWSBackupRestoreRole"
  description        = "Allows the AWS Backup Restore to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.example-aws-backup-service-assume-role-policy-doc.json

  tags = {
    Role    = "iam"
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "example-aws-pass-role-backup-service-role" {
  name               = "ExampleAWSBackupPassRole"
  description        = "Allows the AWS Backup Pass role to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.example-aws-backup-service-assume-role-policy-doc.json

  tags = {
    Role    = "iam"
  }
}

resource "aws_iam_role_policy" "example-backup-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-backup-service-policy.policy
  role   = aws_iam_role.example-aws-backup-service-role.name
}

resource "aws_iam_role_policy" "example-restore-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-restore-service-policy.policy
  role   = aws_iam_role.example-aws-restore-backup-service-role.name
}

resource "aws_iam_role_policy" "example-backup-service-pass-role-policy" {
  policy = data.aws_iam_policy_document.example-pass-role-policy-doc.json
  role   = aws_iam_role.example-aws-pass-role-backup-service-role.name
}

###########################################################################################
################################# BACK UPS ################################################
# https://aws.plainenglish.io/aws-backup-plan-for-ebs-volumes-with-terraform-226bdb52160a #
###########################################################################################

locals {
  backups = {
    schedule  = "cron(0 5 ? * MON-FRI *)" /* UTC Time */
    retention = 7 // days
  }
}

resource "aws_backup_vault" "example-backup-vault" {
  name = "example-backup-vault"
  tags = {
    Role    = "backup-vault"
  }
}

resource "aws_backup_plan" "example-backup-plan" {
  name = "example-backup-plan"

  rule {
    rule_name         = "weekdays-every-2-hours-${local.backups.retention}-day-retention"
    target_vault_name = aws_backup_vault.example-backup-vault.name
    schedule          = local.backups.schedule
    start_window      = 60
    completion_window = 300

    lifecycle {
      delete_after = local.backups.retention
    }

    recovery_point_tags = {
      Role    = "backup"
      Creator = "aws-backups"
    }
  }

  tags = {
    Role    = "backup"
  }
}

resource "aws_backup_selection" "example-server-backup-selection" {
  iam_role_arn = aws_iam_role.example-aws-backup-service-role.arn
  name         = "example-server-resources"
  plan_id      = aws_backup_plan.example-backup-plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}