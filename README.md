# SvcCatMan
AWS Service Catalog Manager

## Initial Deployment

This project uses cloudformation gitsync to manage a bootstrap pipeline that
will deploy infrastructure stored in the terraform directory.

Gitsync requires a codeconnection to GitHub & an IAM role for managing the
bootstrap pipeline's cloudformation stack.

### Enable Organisation Access Tokens

* [Create custom GitHub app.](https://docs.github.com/en/apps/creating-github-apps)
  * Repository Permissions:
    * Administration: Read & Write
    * Contents:       Read & Write
    * Metadata:       Read-only
* Save a copy of the PEM file somewhere safe.

### Deploy Pre-Requisite Stack

```bash
  aws cloudformation deploy \
  --template-file bootstrap/pre-requisites.yaml \
  --stack-name "SvcCatMan-pre-requisites" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodeStarConnectionName=<GitHubOrganisationName>
```

[Approve pending connection.](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html)

### Update GitHub Configuration Secret

Base64 encode GitHub PEM file:
```bash
base64 -i <GITHUB_APP_PEM_FILE_PATH> > encoded_github_app_pem_file
```

```bash
  aws secretsmanager update-secret \
  --secret-id github_app_config \
  --secret-string '{
    "github_app_id":"<GITHUB_APP_ID>",
    "github_ app_installation_id":"<GITHUB_APP_INSTALLATION_ID>",
    "encoded_github_app_pem_file":"<ENCODED_GITHUB_APP_PEM_FILE>"
  }'
```

### Manually Deploy Management Pipeline

```bash
  aws cloudformation deploy \
  --template-file bootstrap/management-pipeline.yaml \
  --stack-name "SvcCatMan-management-pipeline" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    GitHubAppConfigurationSecretArn="<GITHUB_TOKEN_SECRET_ARN>" \
    CodeConnectionARN="<CODECONNECTION_ARN>"
```

### Deploy Repository Link

```bash
  aws cloudformation deploy \
  --template-file bootstrap/repository-link.yaml \
  --stack-name "SvcCatMan-repository-link" \
  --parameter-overrides \
    OrganisationName="<GITHUB_ORGANISATION_NAME>"
    RepositoryName="<GITHUB_REPOSITORY_NAME>" \
    CodeStarConnectionArn="<CODECONNECTION_ARN>"
```
