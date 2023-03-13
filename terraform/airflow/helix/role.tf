resource "aws_iam_role" "helix_mwaa_execution_role" {
  name               = "${var.prefix}-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "airflow-env.amazonaws.com",
          "ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"
         ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "mwaa_service_policy_document" {
  statement {
    sid       = ""
    actions   = ["airflow:PublishMetrics"]
    effect    = "Allow"
    resources = ["arn:aws:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${var.prefix}"]
  }

  statement {
    sid     = ""
    actions = ["s3:ListAllMyBuckets"]
    effect  = "Allow"
    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/*"
    ]
  }

  statement {
    sid = ""
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:PutObject*"
    ]
    effect = "Allow"
    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/*",
      "arn:aws:s3:::ml-model-db",
      "arn:aws:s3:::ml-model-db/*",
      "arn:aws:s3:::ml-cellar",
      "arn:aws:s3:::ml-cellar/*",

    ]
  }

  statement {
    sid = ""
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = ""
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:DescribeLogGroups"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.prefix}-*"]
  }

  statement {
    sid       = ""
    actions   = ["cloudwatch:PutMetricData"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = ""
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    effect    = "Allow"
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:*:airflow-celery-*"]
  }

  statement {
    sid = ""
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    effect        = "Allow"
    not_resources = ["arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "sqs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
  }

  statement {
    sid = ""
    actions = [
      "ecs:PutAttributes",
      "ecs:ListAttributes",
      "ecs:UpdateContainerInstancesState",
      "ecs:StartTask",
      "ecs:RegisterContainerInstance",
      "ecs:DescribeTaskSets",
      "ecs:DescribeTaskDefinition",
      "ecs:SubmitAttachmentStateChanges",
      "ecs:CreateCapacityProvider",
      "ecs:DeregisterTaskDefinition",
      "ecs:ListServices",
      "ecs:Poll",
      "ecs:UpdateService",
      "ecs:DescribeCapacityProviders",
      "ecs:CreateService",
      "ecs:RunTask",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:StopTask",
      "ecs:DescribeServices",
      "ecs:SubmitContainerStateChange",
      "ecs:DescribeContainerInstances",
      "ecs:DeregisterContainerInstance",
      "ecs:TagResource",
      "ecs:DescribeTasks",
      "ecs:UntagResource",
      "ecs:PutClusterCapacityProviders",
      "ecs:ListTaskDefinitions",
      "ecs:UpdateTaskSet",
      "ecs:CreateTaskSet",
      "ecs:ListClusters",
      "ecs:SubmitTaskStateChange",
      "ecs:DiscoverPollEndpoint",
      "ecs:PutAccountSettingDefault",
      "ecs:UpdateClusterSettings",
      "ecs:DeleteTaskSet",
      "ecs:DescribeClusters",
      "ecs:PutAccountSetting",
      "ecs:ListAccountSettings",
      "ecs:ListTagsForResource",
      "ecs:StartTelemetrySession",
      "ecs:ListTaskDefinitionFamilies",
      "ecs:UpdateContainerAgent",
      "ecs:ListContainerInstances",
      "ecs:UpdateServicePrimaryTaskSet",
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    sid = ""
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = ""
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/dsci_monitor_log_prod"
    ]
  }

  statement {
    sid = ""
    actions = [
      "sns:Publish"
    ]
    resources = [
      "arn:aws:sns:${data.aws_region.current.name}:127579856528:prospects"
    ]
  }

  statement {
    sid = ""
    actions = [
      "lambda:*"
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:dsci-cellar-*"
    ]
  }

  statement {
    sid = ""
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "mwaa_service_policy" {
  name   = "${var.prefix}-service-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.mwaa_service_policy_document.json
}

resource "aws_iam_role_policy_attachment" "helix-mwaa" {
  role       = aws_iam_role.helix_mwaa_execution_role.name
  policy_arn = aws_iam_policy.mwaa_service_policy.arn
}

# Give execution role access to main account secrets manager
resource "aws_iam_role_policy_attachment" "sercrets_role_policy_attachment" {
  role       = aws_iam_role.helix_mwaa_execution_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/data-secrets-ro"
}