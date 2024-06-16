include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  params      = local.common_vars.locals.common_parameters
  environment = local.common_vars.locals.environment_name
  tags        = local.common_vars.locals.common_tags
}

dependency "eks" {
  config_path = "../../eks/"
}

terraform {
  source = "../../../../../terraform/modules/aws/irsa///"
}

inputs = {
  cluster_id = dependency.eks.outputs.eks_cluster_name

  cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url

  iam_assumable_roles_with_oidc_and_policies = {

    aws-ebs-csi-controller = {
      role_name = "ebs-csi-controller-sa-${dependency.eks.outputs.eks_cluster_name}"

      oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

      iam_policy = {
        name   = "ebs-csi-controller-sa-${dependency.eks.outputs.eks_cluster_name}"
        policy = file("policies/policy.json")
      }
    }
  }

  tags = local.tags
}
