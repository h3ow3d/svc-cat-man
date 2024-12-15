# SvcCatMan
AWS Service Catalog Manager

## Initial Deployment

This project uses cloudformation gitsync to manage a bootstrap pipeline that
will deploy infrastructure stored in the terraform directory.

Gitsync requires a codeconnection to GitHub & an IAM role for managing the
bootstrap pipeline's cloudformation stack.

### Enable Organisation Access Tokens

* [Set a token access policy for the GitHub organisation.](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization)
* [Create fine-grained access token.](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
  * Owner: Organisation
  * Permissions:
      * Administration: Read/Write
      * Content:        Read/Write
      * Metadata:       Read-Only
* Save a copy of the token somewhere safe.

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

### Update GitHub Token Secret

```bash
  aws secretsmanager update-secret \
  --secret-id github_token \
  --secret-string '{"github_organisation_pat":"<GITHUB_TOKEN>"}'
```

### Manually Deploy Management Pipeline

```bash
  aws cloudformation deploy \
  --template-file bootstrap/management-pipeline.yaml \
  --stack-name "SvcCatMan-management-pipeline" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EnableJSM=false \
    GitHubSecretARN="<GITHUB_TOKEN_SECRET_ARN>" \
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
