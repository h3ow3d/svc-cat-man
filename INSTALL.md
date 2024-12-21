# Initial Deployment

This project uses cloudformation gitsync to manage a bootstrap pipeline that
will deploy infrastructure stored in the terraform directory.

Gitsync requires a codeconnection to GitHub & an IAM role for managing the
bootstrap pipeline's cloudformation stack.

## Deploy Pre-Requisite Stack

```bash
  aws cloudformation deploy \
  --template-file bootstrap/001-pre-requisites.yaml \
  --stack-name "SvcCatMan-pre-requisites" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodeStarConnectionName=<GitHubOrganisationName>
```

[Approve pending connection.](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html)

## Manually Deploy Management Pipeline

```bash
  aws cloudformation deploy \
  --template-file bootstrap/002-management-pipeline.yaml \
  --stack-name "SvcCatMan-management-pipeline" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    GitHubAppConfigurationSecretArn="<GITHUB_TOKEN_SECRET_ARN>" \
    CodeConnectionARN="<CODECONNECTION_ARN>"
```

## Deploy Repository Link

```bash
  aws cloudformation deploy \
  --template-file bootstrap/003-repository-link.yaml \
  --stack-name "SvcCatMan-repository-link" \
  --parameter-overrides \
    OrganisationName="<GITHUB_ORGANISATION_NAME>"
    RepositoryName="<GITHUB_REPOSITORY_NAME>" \
    CodeStarConnectionArn="<CODECONNECTION_ARN>"
```
