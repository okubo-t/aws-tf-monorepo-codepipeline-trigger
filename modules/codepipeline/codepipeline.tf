resource "aws_codepipeline" "this" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_store.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider = "CodeCommit"
      category = "Source"
      configuration = {
        BranchName           = var.branch_name
        PollForSourceChanges = "false"
        RepositoryName       = var.repository_name
      }
      name             = var.repository_name
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      role_arn         = aws_iam_role.codepipeline_codecommit.arn
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      name             = aws_codebuild_project.this.name
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      role_arn         = aws_iam_role.codepipeline_codebuild.arn
    }
  }
}
