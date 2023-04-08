resource "aws_cloudwatch_event_rule" "this" {
  name = var.event_rule_name
  event_pattern = jsonencode({
    detail-type : [
      "CodeCommit Repository State Change"
    ],
    resources : [
      "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.repository_name}"
    ],
    source : [
      "aws.codecommit"
    ],
    detail : {
      event : [
        "referenceCreated",
        "referenceUpdated"
      ],
      referenceName : [
        "${var.branch_name}"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.id
  target_id = "InvokeLambdaFunction"
  arn       = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}"
}
