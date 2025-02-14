
locals {

  env_name = var.common_tags["oEnvironment"]

  aws_region = data.aws_region.current.name
  acc_id     = data.aws_caller_identity.current.account_id

  policy_statement_defs = {
    CreateLogGroup = {
      sid                 = "CreateLogGroup"
      effect              = "Allow"
      actions             = ["logs:CreateLogGroup"]
      resources           = ["arn:aws:logs:${local.aws_region}:${local.acc_id}:*"]
      not_actions         = []
      not_resources       = []
      principals_defs     = {}
      not_principals_defs = {}
      condition_defs      = {}
    }
    CreateLogs = {
      sid                 = "CreateLogs"
      effect              = "Allow"
      actions             = ["logs:CreateLogStream", "logs:PutLogEvents"]
      resources           = ["arn:aws:logs:${local.aws_region}:${local.acc_id}:log-group:/aws/lambda/${var.lambda_function_config["name"]}:*"]
      not_actions         = []
      not_resources       = []
      principals_defs     = {}
      not_principals_defs = {}
      condition_defs      = {}
    }
    CloudWatchLogGroupPutRetention = {
      sid                 = "CloudWatchLogGroupPutRetention"
      effect              = "Allow"
      actions             = ["logs:DescribeLogGroups", "logs:PutRetentionPolicy"]
      resources           = ["arn:aws:logs:${local.aws_region}:${local.acc_id}:log-group:*"]
      not_actions         = []
      not_resources       = []
      principals_defs     = {}
      not_principals_defs = {}
      condition_defs      = {}
    },
  }

}

################################### Data Lookup ########################################

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


################################### IAM ########################################

# IAM Role
resource "aws_iam_role" "lambda" {
  name               = var.lambda_function_config["name"]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(var.common_tags,
    tomap({
      "Name"  = "lexrl_${var.lambda_function_config["name"]}",
      "uRole" = "IAM Role"
    })
  )
}

# IAM Policy
module "iam_policy_doc-lambda" {
  source = "../../data-iam_policy_doc"

  policy_id             = var.lambda_function_config["name"]
  policy_statement_defs = local.policy_statement_defs
}
resource "aws_iam_policy" "iam_policy-lambda" {
  name        = var.lambda_function_config["name"]
  description = "Lambda - Cloudwatch logging and setting of retention for all log groups"
  policy      = module.iam_policy_doc-lambda.iam_policy_doc_obj.json
}
resource "aws_iam_role_policy_attachment" "iam_policy_att-lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.iam_policy-lambda.arn
}


################################### Lambda ########################################

# On-the-fly creation of the lambda package zip
data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = "${path.module}/source"
  output_path = "${path.cwd}/lambda_source_${var.lambda_function_config["name"]}.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_config["name"]
  description   = "Sets retention of Cloudwatch Logs which are Never Expire"

  role = aws_iam_role.lambda.arn

  filename         = data.archive_file.lambda_source.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)

  memory_size = var.lambda_function_config["memory_size"]
  timeout     = var.lambda_function_config["timeout"]
  handler     = var.lambda_function_config["handler"]
  runtime     = var.lambda_function_config["runtime_identifier"]

  environment {
    variables = {
      enable_set_retention_action = var.enable_set_retention_action
      classification_json         = var.classification_json
    }
  }

  tags = merge(
    var.common_tags,
    tomap({
      "Name"  = var.lambda_function_config["name"],
      "uRole" = "Lambda Function"
    })
  )
}


################################### Cloudwatch Trigger ########################################

resource "aws_cloudwatch_event_rule" "cw_cron_rule" {
  name                = "lambda_${var.lambda_function_config["name"]}"
  description         = "Event Pattern trigger cron(${upper(var.lambda_trigger_cron_pattern)})  for Lambda Function ${var.lambda_function_config["name"]}"
  schedule_expression = "cron(${upper(var.lambda_trigger_cron_pattern)})"
}

resource "aws_cloudwatch_event_target" "cw_cron_target" {
  target_id = "lambda_${var.lambda_function_config["name"]}"
  rule      = aws_cloudwatch_event_rule.cw_cron_rule.name
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "cw_cron_permission" {
  statement_id_prefix = "${var.lambda_function_config["name"]}-"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.lambda.function_name
  principal           = "events.amazonaws.com"
  source_arn          = aws_cloudwatch_event_rule.cw_cron_rule.arn
}


################################### Cloudwatch Alarm ########################################

resource "aws_cloudwatch_metric_alarm" "exec_error" {
  alarm_name        = "${var.lambda_function_config["name"]}-exec_error"
  alarm_description = "Alerts on any execution errors"
  namespace         = "AWS/Lambda"
  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
  metric_name         = "Errors"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  period              = "60"
  evaluation_periods  = "1"
  actions_enabled     = length(var.cw_alarm_sns_topic_arn_list) > 0 ? "true" : "false"
  alarm_actions       = var.cw_alarm_sns_topic_arn_list
}
