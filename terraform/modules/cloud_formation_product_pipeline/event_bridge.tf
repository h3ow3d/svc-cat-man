data "aws_ssm_parameter" "management_pipeline_name" {
  name = "SvcCatMan-management-pipeline-name"
}

resource "aws_cloudwatch_event_rule" "trigger_pipeline_on_success" {
  name        = "trigger-${data.aws_ssm_parameter.management_pipeline_name.value}-on-success"
  description = "Triggers the pipeline when a related event occurs"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"],
    detail-type = ["CodePipeline Pipeline Execution State Change"],
    detail = {
      pipeline = [data.aws_ssm_parameter.management_pipeline_name.value],
      state    = ["SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_pipeline_target" {
  rule = aws_cloudwatch_event_rule.trigger_pipeline_on_success.name
  arn  = aws_codepipeline.product_pipeline.arn

  role_arn = aws_iam_role.eventbridge_trigger_role.arn

  input = jsonencode({
    pipelineName = aws_codepipeline.product_pipeline.id
  })
}

resource "aws_iam_role" "eventbridge_trigger_role" {
  name = "eventbridge-trigger-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_trigger_policy" {
  name = "eventbridge-trigger-policy"
  role = aws_iam_role.eventbridge_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "codepipeline:StartPipelineExecution",
        Resource = aws_codepipeline.product_pipeline.arn
      }
    ]
  })
}
