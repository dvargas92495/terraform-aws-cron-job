variable "lambdas" {
  type        = list
  description = "The list of lambdas that run on this schedule."
  default     = []
}

variable "rule_name" {
    type = string
    description = "The name given to the cloudwatch event rule."
}

variable "schedule" {
    type = string
    description = "The schedule expression to pass to the cloudwatch event rule."
}

variable "tags" {
    type        = map
    description = "A map of tags to add to all resources."
    default     = {}
}
