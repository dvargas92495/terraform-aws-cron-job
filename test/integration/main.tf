provider "aws" {
    region = "us-east-1"
}

module "aws-cron-job" {
    source = "../.."

    rule_name = "example"
    lambdas = [
        "first-lambda",
        "second-lambda"
    ]
    schedule = "cron(0 0 0 * ? *)"
}
