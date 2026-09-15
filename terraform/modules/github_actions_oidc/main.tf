data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only the dev environment of this repository can assume the role.
    # GitHub configured this organization for immutable OIDC subjects, which
    # include the stable owner and repository IDs after their names.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_organization}@${var.github_organization_id}/${var.github_repository}@${var.github_repository_id}:environment:${var.github_environment}",
      ]
    }
  }
}

# This provider is created once per AWS account for GitHub Actions OIDC.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []

  tags = merge(
    var.tags,
    {
      Name = "${var.role_name}-oidc"
    }
  )
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name = var.role_name
    }
  )
}

data "aws_iam_policy_document" "terraform_deploy" {
  #checkov:skip=CKV_AWS_111: Several EC2 create/delete APIs used for VPC networking do not support resource-level IAM conditions.
  #checkov:skip=CKV_AWS_356: AWS requires Resource "*" for the listed EC2 describe and VPC networking APIs.
  # The Terraform environment manages only VPC, EC2, Security Group, NAT and
  # related EC2 networking resources. Use individual API actions rather than ec2:*.
  statement {
    sid    = "ManageLabEc2Infrastructure"
    effect = "Allow"
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteKeyPair",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:Describe*",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ImportKeyPair",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:MonitorInstances",
      "ec2:ReleaseAddress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:UnmonitorInstances",
    ]
    resources = ["*"]
  }

  # Permit Terraform to read and update its state objects in the dedicated bucket.
  statement {
    sid    = "ManageTerraformState"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}",
      "arn:aws:s3:::${var.state_bucket_name}/*",
    ]
  }

  # Permit Terraform to create and release locks in its dedicated DynamoDB table.
  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.lock_table_name}"]
  }
}

resource "aws_iam_role_policy" "terraform_deploy" {
  name   = "${var.role_name}-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.terraform_deploy.json
}
