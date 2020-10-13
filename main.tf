# lambda resource requires either filename or s3... wow
data "archive_file" "dummy" {
  type        = "zip"
  output_path = "./dummy.zip"

  source {
    content   = "// TODO IMPLEMENT"
    filename  = "dummy.js"
  }
}

data "aws_iam_policy_document" "assume_lambda_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_cron_policy" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "ses:sendEmail"
    ]
    resources = ["*"]
	}
	
  statement	{
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement	{
    actions = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_cron_policy" {
  name = "${var.rule_name}-lambda-cron"
  policy = data.aws_iam_policy_document.lambda_cron_policy.json
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.rule_name}-lambda-cron"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cron_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  for_each         = var.lambdas  
  function_name    = "${var.rule_name}_${each.value}"
  role             = data.aws_iam_role.lambda_role.arn
  handler          = "${each.value}.handler"
  runtime          = "nodejs12.x"
  filename         = "dummy.zip"
  publish          = false
  tags = var.tags
}
 
resource "aws_cloudwatch_event_rule" "trigger_query" {
  name        = var.rule_name
  description = "Triggers based on the input schedule on various lambdas."
  schedule_expression = var.schedule
}

resource "aws_lambda_permission" "allow_query" {
  for_each      = var.lambdas
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[each.value].arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_query.arn
}

resource "aws_cloudwatch_event_target" "trigger_scheduler" {
  for_each  = var.lambdas
  rule      = aws_cloudwatch_event_rule.trigger_query.name
  arn       = aws_lambda_function.lambda_function[each.value].arn
}

data "aws_iam_policy_document" "deploy_policy" {
    statement {
      actions = [
        "lambda:UpdateFunctionCode"
      ]

      resources = values(aws_lambda_function.lambda_function)[*].arn
    }
}

resource "aws_iam_user" "deploy_lambda" {
  user_name  = "${var.rule_name}-cron"
  path       = "/"
}

resource "aws_iam_access_key" "deploy_lambda" {
  user  = aws_iam_user.deploy_lambda.name
}

resource "aws_iam_user_policy" "deploy_lambda" {
  user   = data.aws_iam_user.deploy_lambda.user_name
  policy = data.aws_iam_policy_document.deploy_policy.json
}
