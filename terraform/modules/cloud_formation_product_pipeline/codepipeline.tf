locals {
  product_repository_name = var.product_source == "local" ? "${var.github_organisation}/${var.github_repository}" : null
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}

resource "aws_codepipeline" "product_pipeline" {
  name     = var.name
  role_arn = aws_iam_role.codepipeline_role.arn

  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.artifact_storage.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["main"]
        }
        file_paths {
          includes = [
            "terraform/products/${var.name}/config.json",
            "terraform/products/${var.name}/template.yaml"
          ]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = local.product_repository_name
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ServiceCatalog"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProductId             = var.product_id
        ConfigurationFilePath = "terraform/products/${var.name}/config.json"
      }
    }
  }
}

resource "aws_s3_bucket" "artifact_storage" {
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  # checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration
  # checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  # checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  # checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  bucket = "${var.name}-artifact-storage"
}

resource "aws_s3_bucket_public_access_block" "artifact_storage_pab" {
  bucket = aws_s3_bucket.artifact_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  # checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints
  # checkov:skip=CKV_AWS_356:Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions
  statement {
    sid    = "AllowArtifactStorageAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.artifact_storage.arn,
      "${aws_s3_bucket.artifact_storage.arn}/*"
    ]
  }

  statement {
    sid    = "AllowUseCodeConnection"
    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection",
      "codeconnections:UseConnection"
    ]
    resources = [var.github_connection_arn]
  }

  statement {
    sid    = "AllowTriggerCodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowServiceCatalogProvisioning"
    effect = "Allow"

    actions = [
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:DescribeProduct",
      "servicecatalog:UpdateProduct"
    ]

    resources = [
      var.product_arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudformation:ValidateTemplate"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
