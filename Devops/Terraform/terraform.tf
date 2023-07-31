terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "ap_southeast_2"
}

#not allowed for variables
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-remote-state-storage-land-tasker"
    region         = "ap-southeast-2"
    key            = "./terraform.tfstate"
    profile        = "default"
    dynamodb_table = "terraform-state-lock-dynamodb-land-tasker"
  }
}
