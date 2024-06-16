include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  params      = local.common_vars.locals.common_parameters
  environment = local.common_vars.locals.environment_name
  tags        = local.common_vars.locals.common_tags

  cluster_name = local.params.cluster_name
}

dependency "eks" {
  config_path = "../../eks"
}

dependency "irsa_csi" {
  config_path = "../../irsa/ebs-sc-controller///"
}

terraform {
  source = "git::ssh://git@github.com/stepanyan-areg/terraform-met.git//infra/terraform/modules/k8s/helm?ref=main"
}


inputs = {
  // kubeconfig = dependency.eks.outputs.kubeconfig_filename

  release_name   = "aws-ebs-csi-driver"
  repository_url = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart_name     = "aws-ebs-csi-driver"
  chart_version  = "2.10.1"
  namespace      = "kube-system"

  values_file = templatefile("values.tmpl",
    {
      "role_arn" = dependency.irsa_csi.outputs.roles.aws-ebs-csi-controller.iam_role_arn,
      "region"   = "eu-west-1"
    }
  )
}
