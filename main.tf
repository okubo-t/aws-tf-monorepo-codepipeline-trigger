locals {
  aws_region = "ap-northeast-1"

  repository_name = "monorepo"
  branch_name     = "main"

  ssm_parameter_name = "codepipeline-trigger"
  ssm_parameter_value = jsonencode({
    "project1" : "project1-codepipeline",
    "project2" : "project2-codepipeline"
  })

  event_rule_name = "monorepo-change-event"

  function_name = "codepipeline-trigger"

  project1_codepipeline_name = "project1-codepipeline"
  project2_codepipeline_name = "project2-codepipeline"
}

module "ssm" {
  source = "./modules/ssm"

  ssm_parameter_name  = local.ssm_parameter_name
  ssm_parameter_value = local.ssm_parameter_value
}

module "codecommit" {
  source = "./modules/codecommit"

  repository_name = local.repository_name
}

module "eventbridge" {
  source = "./modules/eventbridge"

  event_rule_name = local.event_rule_name
  function_name   = local.function_name
  repository_name = local.repository_name
  branch_name     = local.branch_name
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = local.function_name
  ssm_parameter_name = local.ssm_parameter_name
}

module "project1_codepipeline" {
  source = "./modules/codepipeline"

  codepipeline_name = local.project1_codepipeline_name
  repository_name   = local.repository_name
  branch_name       = local.branch_name
}

module "project2_codepipeline" {
  source = "./modules/codepipeline"

  codepipeline_name = local.project2_codepipeline_name
  repository_name   = local.repository_name
  branch_name       = local.branch_name
}
