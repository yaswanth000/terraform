module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.20.0"
  cluster_name = local.cluster_name
  cluster_version = var.kubernetes_version

  enable_irsa = true
  cluster_endpoint_public_access  = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  tags = {
    cluster = "eks-terraform"
  }
  
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }
  eks_managed_node_groups = {
    node_group1 = {
        min_size = 1
        max_size = 5
        desired_size = 2
    }
  }
  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = ["node_group1"]
      principal_arn     = "arn:aws:iam::088285363738:role/Eks_cluster_role"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }
}
