terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      find_in_parent_folders("common.tfvars"),
    ]

    optional_var_files = [
      find_in_parent_folders("regional.tfvars"),
    ]
  }

  extra_arguments "disable_input" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }
}

generate "main_providers" {
  path      = "main_providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
    provider "aws" {
      region = var.aws_region

      allowed_account_ids = var.allowed_account_ids

      assume_role {
        role_arn     = var.role_arn
        session_name = var.session_name
        external_id  = var.external_id
      }

      skip_metadata_api_check     = true
      skip_region_validation      = true
      skip_credentials_validation = true
    }

    variable "aws_region" {
      description = "AWS region to create infrastructure in"
      type        = string
      default     = "eu-west-1"
    }

    variable "role_arn" {
      description = "IAM role to be assumed by terragrunt"
      type        = string
      default     = "arn:aws:iam::115525075501:role/DevOps"
    }

    variable "session_name" {
      description = "Session name to use when assuming the role"
      type        = string
      default     = "terragrunt"
    }

    variable "external_id" {
      description = "External identifier to use when assuming the role"
      type        = string
      default     = null
    }

    variable "allowed_account_ids" {
      description = "List of allowed AWS account ids to create infrastructure in"
      type        = list(string)
    }

    variable "common_parameters" {
      description = "Map of common parameters shared across all infrastructure resources"
      type        = map(string)
      default     = {}
    }

    variable "common_tags" {
      description = "Map of common tags shared across all infrastructure resources"
      type        = map(string)
      default     = {
        Project     = "ExampleProject"
        Environment = "dev"
      }
    }
  EOT
}

remote_state {
  backend      = "s3"
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }

  config = {
    encrypt        = true
    region         = "eu-west-1"
    key            = format("%s/terraform.tfstate", path_relative_to_include())
    bucket         = format("terraform-states-%s", get_aws_account_id())
    dynamodb_table = format("terraform-states-%s", get_aws_account_id())

    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
}
