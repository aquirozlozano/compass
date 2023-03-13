data "terraform_remote_state" "datascience_acct" {
  backend = "s3"

  config = {
    bucket = "compass-terraform"
    key    = "datascience-acct/global-resources/account/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "data-vpc" {
  backend = "s3"

  config = {
    bucket = "compass-terraform"
    key    = "devops/data-vpc"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cnvrg" {
  backend = "s3"

  config = {
    bucket = "compass-terraform"
    key    = "cnvrg/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "main-vpc" {
  backend = "s3"

  config = {
    bucket = "compass-terraform"
    key    = "main-vpc"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "mindshare-data-store-dev" {
  backend = "s3"
  config = {
    bucket   = "dsci-terraform"
    key      = "mindshare-data-store/dev/terraform.tfstate"
    region   = "us-west-2"
    role_arn = data.terraform_remote_state.datascience_acct.outputs.assume_role_arn
  }
}

data "terraform_remote_state" "mindshare-data-store-prod" {
  backend = "s3"
  config = {
    bucket   = "dsci-terraform"
    key      = "mindshare-data-store/prod/terraform.tfstate"
    region   = "us-west-2"
    role_arn = data.terraform_remote_state.datascience_acct.outputs.assume_role_arn
  }
}