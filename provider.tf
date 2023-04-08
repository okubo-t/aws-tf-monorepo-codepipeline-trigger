terraform {

  required_providers {

    aws = {
      version = ">= 4.61.0"
      source  = "hashicorp/aws"

    }
  }
}

provider "aws" {

  region = local.aws_region

}
