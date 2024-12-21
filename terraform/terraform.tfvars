portfolios = [
  {
    name          = "examples"
    description   = "Portfolio for example products."
    provider_name = "tech_org"
    groups        = ["Administrators", "Developers"]

    products = [
      {
        name   = "example-bucket"
        owner  = "platform"
        type   = "CLOUD_FORMATION_TEMPLATE"
        source = "local"
        launch_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonS3FullAccess",
          "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
        ]
      },
      {
        name   = "example-table"
        owner  = "platform"
        type   = "CLOUD_FORMATION_TEMPLATE"
        source = "local"
        launch_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
          "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
        ]
      }
    ]
  },
  {
    name          = "Web Service"
    description   = "Portfolio for web hosting."
    provider_name = "tech_org"
    groups        = ["Administrators", "Developers"]

    products = [
      {
        name   = "static-website"
        owner  = "platform"
        type   = "CLOUD_FORMATION_TEMPLATE"
        source = "local"
        launch_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonS3FullAccess",
          "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess",
          "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
          "arn:aws:iam::aws:policy/AWSCodeStarFullAccess"
        ]
      }
    ]
  }
]
