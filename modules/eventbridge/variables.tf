data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "event_rule_name" {}
variable "repository_name" {}
variable "branch_name" {}
variable "function_name" {}
