# SvcCatMan

This project manages portfolios & products in AWS Service Catalog.

It consists of a management pipeline & Service Catalog Manager (Terraform
deployment).

## Management Pipeline

The management pipeline needs to be manually deployed to bootstrap the project.
Instructions for bootstrapping can be found [here](INSTALL.md).

Once bootstrapped, updates to the management pipeline will be handled by
[AWS Cloudformation GitSync](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/git-sync.html).

## Service Catalog Manager

The core of the project is stored in the [terraform directory](terraform/).

### Products

A product is deployed with:
* A GitHub repository:
  * With a base cloudformation template.
  * Branches: main, development & production.
    * development & production are protected from direct commits.
* An AWS Codepipeline configured to deploy the cloudformation template as it is
promoted to subsequent environments.
