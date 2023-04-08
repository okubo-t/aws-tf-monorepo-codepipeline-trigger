resource "aws_iam_role" "this" {
  name = var.function_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "this" {
  name = "LambdaExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:*:*:parameter/${var.ssm_parameter_name}"
      },
      {
        Action : [
          "codecommit:GetCommit",
          "codecommit:GetDifferences"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        Action : [
          "codepipeline:StartPipelineExecution"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
