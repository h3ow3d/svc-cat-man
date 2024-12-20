data "aws_ssm_parameter" "management_pipeline_name" {
  name = "SvcCatMan-management-pipeline-name"
}

resource "aws_cloudwatch_event_rule" "trigger_pipeline_on_success" {
  name        = "trigger-product-pipelines-on-success"
  description = "Triggers product pipelines on success of Service Catalog pipeline"

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
  for_each = module.cloud_formation_product_pipeline

  rule = aws_cloudwatch_event_rule.trigger_pipeline_on_success.name
  arn  = each.value.product_pipeline_arn

  role_arn = aws_iam_role.eventbridge_trigger_role.arn

  input = jsonencode({
    pipelineName = each.key
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

data "aws_iam_policy_document" "eventbridge_trigger_policy" {
  statement {
    effect = "Allow"

    actions = [
      "codepipeline:StartPipelineExecution"
    ]

    resources = [
      for product_pipeline in module.cloud_formation_product_pipeline : product_pipeline.product_pipeline_arn
    ]
  }
}


resource "aws_iam_role_policy" "eventbridge_trigger_policy" {
  name = "eventbridge-trigger-policy"
  role = aws_iam_role.eventbridge_trigger_role.id

  policy = data.aws_iam_policy_document.eventbridge_trigger_policy.json
}
