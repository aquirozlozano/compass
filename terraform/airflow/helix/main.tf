terraform {

  backend "s3" {
    bucket         = "compass-terraform"
    key            = "data-systems/mwaa-helix/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = "1.3.4"

}

provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = [data.terraform_remote_state.datascience_acct.outputs.account_id]
  assume_role {
    role_arn = data.terraform_remote_state.datascience_acct.outputs.assume_role_arn
  }

  default_tags {
    tags = {
      businessunit = "degrees"
      group        = "data-science"
      portfolio    = "data"
      source       = "Terraform: compassinc/tf-datascience-acct/airflow/helix-mwaa"
    }
  }
}