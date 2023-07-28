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

#not allowed for variables
terraform {
  backend "s3" {
    encrypt = true
    bucket = "land-tasker-terraform-remote-state-storage"
    region = "ap-southeast-2"
    key = "./terraform.tfstate"
    profile = "default"
    dynamodb_table = "land-tasker-terraform-state-lock-dynamodb"
  }
}
