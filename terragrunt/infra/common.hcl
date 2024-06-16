locals {
  environment_name = "dev"

  common_tags = {
    Project     = "ExampleProject"
    Environment = local.environment_name
  }

  # VPC configuration
  vpc = {
    cidr = "10.0.0.0/16"
    azs = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c"
    ]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    enable_nat_gateway = true
    enable_vpn_gateway = true
  }

  # EKS configuration
  eks = {
    cluster_addons = {
      coredns = {
        most_recent = true
      }
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent = true
      }
    }
    eks_managed_node_group_defaults = {
      instance_types = ["t2.micro"]
    }
    eks_managed_node_groups = {
      example = {
        min_size     = 1
        max_size     = 5
        desired_size = 2
        instance_types = ["t2.2xlarge"]
        capacity_type  = "SPOT"
        disk_size = 100
        use_custom_launch_template = false
      }
    }
  }

  common_parameters = {
    cluster_name = "eks-${local.environment_name}"
  }
}
