# SvcCatMan
Project Description: Develop a service catalogue management solution

## Bootstrap
- [ ] Automate/script bootstrap process
  - [ ] [Investigate implementing the bootstrap stacks as a nested stack.](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-stack.html#cfn-cloudformation-stack-templatebody)
  - [ ] [Investigate patterns that are supported by AWS' compliance program.](https://aws.amazon.com/compliance/services-in-scope/)

## Product OAT
- [ ] [Is Cloudformation hooks an alternative to product codepipeline customisation?](https://eu-west-2.console.aws.amazon.com/cloudformation/hooks/overview?region=eu-west-2)

## Service Catalog Manager
- [ ] PRIORITY: Refactor project to support custom GithHub App authentication
  - [ ] [Refactor GitHub provider to implement](https://registry.terraform.io/providers/integrations/github/latest/docs#github-app-installation)
  - [ ] [Document GitHub App registration](https://docs.github.com/en/apps/creating-github-apps)
  - [ ] Refactor pipeline to reference GitHub App PEM file
- [ ] Refactor config.yml to terraform variable
- [ ] Template backend file
- [ ] Add terraform directory trigger to management pipeline
- [ ] Address checkov inline ignores

## Project Groundwork
- [ ] Commit lint, automate changelog
- [ ] Commit lint, config file for project scope
