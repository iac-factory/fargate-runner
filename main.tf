data "aws_security_groups" "sgs" {
    filter {
        name   = "group-name"
        values = [ "capstone-bastionhost" ]
    }

    filter {
        name   = "vpc-id"
        values = [ data.aws_vpc.vpc.id ]
    }
}

data "aws_vpc" "vpc" {
    filter {
        name   = "tag:Name"
        values = [ var.vpc-name ]
    }
}

data "aws_subnets" "subnet-data-array" {
    filter {
        name   = "vpc-id"
        values = [ data.aws_vpc.vpc.id ]
    }
}

data "aws_subnet" "subnet-mapping" {
    for_each = toset(data.aws_subnets.subnet-data-array.ids)

    id = each.value

    vpc_id = data.aws_vpc.vpc.id
}

resource "aws_instance" "nexus" {
    for_each = toset(data.aws_subnets.subnet-data-array.ids)

    ami                         = module.linux-2-ami-id.ami-identifiers[ "linux-2" ]
    instance_type               = "t3.micro"
    associate_public_ip_address = false

    security_groups = data.aws_security_groups.sgs.ids
    iam_instance_profile   = aws_iam_instance_profile.instance.name

    subnet_id = each.value

    tags = {
        Subnet = each.key
    }

    user_data = join("\n", [
        "systemctl enable amazon-ssm-agent",
        "systemctl start amazon-ssm-agent",
        "yum update -y && yum upgrade --security -y || true",
        "yum install -y docker",
        "usermod -a -G docker ec2-user",
        "systemctl enable docker.service",
        "systemctl start docker.service",
        "curl -L 'https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh' | bash",
        "yum install -y gitlab-runner"
    ])
}

module "trust-boundary" {
    source = "./modules/identity"
}

//################################################################################
//### Trust Policy Documents
//################################################################################
data "aws_iam_policy_document" "ssm-policy-document" {
    statement {
        effect    = "Allow"
        resources = [ "*" ]
        actions   = [
            "ssm:DescribeAssociation",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:DescribeDocument",
            "ssm:GetManifest",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListAssociations",
            "ssm:ListInstanceAssociations",
            "ssm:PutInventory",
            "ssm:PutComplianceItems",
            "ssm:PutConfigurePackageResult",
            "ssm:UpdateAssociationStatus",
            "ssm:UpdateInstanceAssociationStatus",
            "ssm:UpdateInstanceInformation"
        ]
    }
}

data "aws_iam_policy_document" "iam-service-policy-document" {
    statement {
        effect  = "Allow"
        actions = [
            "iam:CreateServiceLinkedRole"
        ]
        resources = [
            "arn:aws:iam::*:role/aws-service-role/*"
        ]
    }
}

data "aws_iam_policy_document" "controller-policy-document" {
    statement {
        effect    = "Allow"
        resources = [ "*" ]
        actions   = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
        ]
    }
}

data "aws_iam_policy_document" "cloud-watch-policy-document" {
    statement {
        effect = "Allow"
        resources = [
            "*"
        ]
        actions = [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
        ]
    }
}

data "aws_iam_policy_document" "ec2-policy-document" {
    statement {
        effect    = "Allow"
        resources = [ "*" ]
        actions = [
            "ec2messages:AcknowledgeMessage",
            "ec2messages:DeleteMessage",
            "ec2messages:FailMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply"
        ]
    }
}

data "aws_iam_policy_document" "kms-policy-document" {
    statement {
        effect = "Allow"
        resources = [
            "*"
        ]
        actions = [
            "kms:*"
        ]
    }
}

data "aws_iam_policy_document" "ecr-policy-document" {
    statement {
        effect = "Allow"
        resources = [
            "*"
        ]
        actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
    }
}

//################################################################################
//### Customer Managed Policies
//################################################################################
resource "aws_iam_policy" "ssm-policy" {
    name = format("%s-SSM-Policy", module.parameter.name)
    policy = data.aws_iam_policy_document.ssm-policy-document.json
}

resource "aws_iam_policy" "controller-policy" {
    name = format("%s-Controller-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.controller-policy-document.json
}

resource "aws_iam_policy" "iam-service-policy" {
    name = format("%s-IAM-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.iam-service-policy-document.json
}

resource "aws_iam_policy" "cloud-watch-policy" {
    name = format("%s-CW-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.cloud-watch-policy-document.json
}

resource "aws_iam_policy" "ec2-policy" {
    name = format("%s-EC2-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.ec2-policy-document.json
}

resource "aws_iam_policy" "kms-policy" {
    name = format("%s-KMS-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.kms-policy-document.json
}

resource "aws_iam_policy" "ecr-policy" {
    name = format("%s-ECR-Policy", module.parameter.name)
    description = "..."
    policy = data.aws_iam_policy_document.ecr-policy-document.json
}

//################################################################################
//### AWS Managed Policies
//################################################################################
data "aws_iam_policy" "ssm-management-core" {
    name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ecr-task-execution" {
    name = "AmazonECSTaskExecutionRolePolicy"
}

//################################################################################
//### IAM Role
//################################################################################
resource "aws_iam_role" "instance" {
    name                  = format("%s-Service-Linked-Role", module.parameter.name)
    path                  = module.iam-path.name
    force_detach_policies = true
    description           = "..."

    assume_role_policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [
            {
                Action    = "sts:AssumeRole"
                Effect    = "Allow"
                Sid       = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
            {
                Action    = "sts:AssumeRole"
                Effect    = "Allow"
                Sid       = ""
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })

    permissions_boundary = (var.boundary) ? format("%s:*", module.trust-boundary.iam-arn-prefix) : null
}

//################################################################################
//### IAM Role Policy Attachments
//################################################################################
resource "aws_iam_role_policy_attachment" "ssm-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.ssm-policy.arn
}

resource "aws_iam_role_policy_attachment" "controller-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.controller-policy.arn
}

resource "aws_iam_role_policy_attachment" "iam-service-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.iam-service-policy.arn
}

resource "aws_iam_role_policy_attachment" "cloud-watch-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.cloud-watch-policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.ec2-policy.arn
}

resource "aws_iam_role_policy_attachment" "kms-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.kms-policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = aws_iam_policy.ecr-policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr-managed-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = data.aws_iam_policy.ecr-task-execution.arn
}

resource "aws_iam_role_policy_attachment" "ssm-managed-policy-attachment" {
    role = aws_iam_role.instance.name
    policy_arn = data.aws_iam_policy.ssm-management-core.arn
}

//################################################################################
//### IAM Instance Profile
//################################################################################
resource "aws_iam_instance_profile" "instance" {
    name = format("%s-EC2-Profile", module.parameter.name)
    path = module.iam-path.name
    role = aws_iam_role.instance.name
}
