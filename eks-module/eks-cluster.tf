# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.8.5"

#   cluster_name = local.cluster_name
#   cluster_version = var.kubernetes_version

#   cluster_endpoint_public_access           = true
#   enable_cluster_creator_admin_permissions = true

#   cluster_addons = {
#     aws-ebs-csi-driver = {
#       service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#     }
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"

#   }

#   eks_managed_node_groups = {
#     one = {
#       name = "node-group-1"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 3
#       desired_size = 2
#     }

#     two = {
#       name = "node-group-2"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 2
#       desired_size = 1
#     }
#   }
# }


# # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# module "irsa-ebs-csi" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "5.39.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }
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