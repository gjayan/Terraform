terraform {
        required_providers {
          aws = {
                source  = "hashicorp/aws"
                version = ">= 2.7.0"
          }
        }
  }

provider "vault" {
  address = "http://3.110.187.144:8200"
  auth_login_userpass {
    username = "gjayan"
    }
}

data "vault_generic_secret" "env" {
  path = "kv-terraform/dev"
}

resource "aws_vpc" "vpc" {
  cidr_block       = vault_generic_secret.env.data["ip"]
  instance_tenancy = "default"

  tags = {
    Name = "Gayathri-demo-vpc"
    Used_By = "Gayathri"

  }
}

