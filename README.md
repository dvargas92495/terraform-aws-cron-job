# aws-cron-job

Creates a cloudwatch event rule and lambdas that run on a specified cron schedule.

## Features

- Creates a cloudwatch event rule using the input cron expression
- Hooks up the cloudwatch event rule to multiple lambda functions
- An IAM user named like `rule_name-cron` is created that is given deployment access to the lambdas

## Usage

```hcl
provider "aws" {
    region = "us-east-1"
}

module "aws_cron_job" {
    source    = "dvargas92495/cron-job/aws"

    rule_name = "example"
    lambdas = [
        "first-lambda",
        "second-lambda"
    ]
    schedule = "cron(0 0 0 * ? *)"
}
```

## Inputs

- `lambdas` are the list of lambdas that run on this schedule.
- `rule_name` is the name given to the cloudwatch event rule.
- `schedule` is the schedule expression to pass to the cloudwatch event rule.
- `tags` tags to add on to lambdas

## Output

- `access_key` the AWS_ACCESS_KEY_ID of the created user
- `secret_key` the AWS_SECRET_ACCESS_KEY of the created user
