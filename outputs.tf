output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}

output "worker_role_arn" {
  value = aws_iam_role.worker_role.arn
}

output "vpc_id" {
  value = aws_vpc.vpc-eks.id
}

output "subnet_id_us-east-1a" {
  value = aws_subnet.subnet-vpc-eks-us-east-1a.id
}

output "subnet_id_us-east-1b" {
  value = aws_subnet.subnet-vpc-eks-us-east-1b.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
