data "archive_file" "source_code" {
  type        = "zip"
  source_file = "${path.module}/src/codepipeline_trigger.py"
  output_path = "${path.module}/dist/codepipeline_trigger.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  runtime          = "python3.9"
  handler          = "codepipeline_trigger.lambda_handler"
  timeout          = 10
  filename         = data.archive_file.source_code.output_path
  source_code_hash = data.archive_file.source_code.output_base64sha256

  environment {
    variables = {
      PARAMETER_NAME = var.ssm_parameter_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.this,
  ]
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"

  depends_on = [
    aws_lambda_function.this,
  ]
}
