terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
  }
  backend "s3" {
    key    = "terraform.tfstate"
    bucket = "terraform-lambdas-commit"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "environment" = var.environment
      "stack_name"  = "${var.environment}-${var.platform_name}"
      "managedBy"   = "terraform"
    }
  }
}
