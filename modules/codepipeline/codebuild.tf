resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.codepipeline_name}-codebuild"
  retention_in_days = 30
}

resource "aws_codebuild_project" "this" {
  name          = "${var.codepipeline_name}-codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
    buildspec       = file("${path.module}/buildspec.yml")
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.codebuild.name
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}
