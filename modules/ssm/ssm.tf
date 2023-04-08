resource "aws_ssm_parameter" "this" {
  name  = var.ssm_parameter_name
  value = var.ssm_parameter_value
  type  = "String"
}
