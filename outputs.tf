output "access_key" {
  description = "The AWS Access Key ID for the IAM deployment user."
  value       = aws_iam_access_key.deploy_lambda.id
}

output "secret_key" {
  description = "The AWS Secret Key for the IAM deployment user."
  value       = aws_iam_access_key.deploy_lambda.secret
}
