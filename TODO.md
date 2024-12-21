# SvcCatMan

Project Description: Develop a service catalogue management solution

## General

- [ ] Implement multiple environments
  - [ ] development
  - [ ] staging
  - [ ] production (based on tags)
- [ ] Push dockerfile to ECR

## Bootstrap

- [ ] Automate/script bootstrap process
  - [ ] [Investigate implementing the bootstrap stacks as a nested stack.](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-stack.html#cfn-cloudformation-stack-templatebody)
  - [ ] [Investigate patterns that are supported by AWS' compliance program.](https://aws.amazon.com/compliance/services-in-scope/)
- [ ] Upgrade management pipeline to v2
  - [ ] Configure CodeStarSourceConnection source provider
- [ ] Move bootstrap buildspecs to bootstrap/ directory
  - [ ] Refactor publish-buildspec workflow to reference migrated dir

## Product OAT

- [ ] [Is Cloudformation hooks an alternative to product codepipeline customisation?](https://eu-west-2.console.aws.amazon.com/cloudformation/hooks/overview?region=eu-west-2)

## Service Catalog Manager

- [x] PRIORITY: Refactor project to support custom GithHub App authentication
  - [x] [Refactor GitHub provider to implement app auth](https://registry.terraform.io/providers/integrations/github/latest/docs#github-app-installation)
  - [x] [Document GitHub App registration](https://docs.github.com/en/apps/creating-github-apps)
  - [x] Refactor pipeline to reference GitHub App PEM file
- [x] Refactor config.yml to terraform variable
- [ ] Template backend file, to support deployment environments
- [ ] Address checkov inline ignores

### EventBridge

- [ ] Migrate event bridge to separate module & include list of product pipeline
      ids

## Project Groundwork

- [ ] Pre-merge checks
- [ ] pr template
- [ ] Commit lint, automate changelog
- [ ] Commit lint, config file for project scope
