include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  tags        = local.common_vars.locals.common_tags
  vpc         = local.common_vars.locals.vpc
}

terraform {
  source = "git::ssh://git@github.com/stepanyan-areg/terraform-met.git//infra/terraform/modules/aws/vpc?ref=main"
}

inputs = {
  name             = "vpc-${local.common_vars.locals.environment_name}"
  cidr             = local.vpc.cidr
  azs              = local.vpc.azs
  private_subnets  = local.vpc.private_subnets
  public_subnets   = local.vpc.public_subnets
  enable_nat_gateway = local.vpc.enable_nat_gateway
  enable_vpn_gateway = local.vpc.enable_vpn_gateway

  tags = merge(
    local.tags,
    {
      Description = "VPC for ${local.common_vars.locals.environment_name} environment"
    }
  )
}
