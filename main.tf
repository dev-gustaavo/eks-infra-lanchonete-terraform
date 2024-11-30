provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "fiap-tech-challenge-terraform-state"
    key            = "eks/terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# IAM ROLE

resource "aws_iam_role" "eks_role" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role" "worker_role" {
  name = "${var.cluster_name}-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_role.name
}

# VPC

resource "aws_vpc" "vpc-eks" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# Criar o Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-eks.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# Criar a Tabela de Rotas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc-eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

# Subnet em us-east-1a
resource "aws_subnet" "subnet-vpc-eks-us-east-1a" {
  vpc_id     = aws_vpc.vpc-eks.id
  cidr_block = cidrsubnet(aws_vpc.vpc-eks.cidr_block, 8, 0)
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-subnet-us-east-1a"
  }
}

# Associar a Tabela de Rotas à Subnet us-east-1a
resource "aws_route_table_association" "subnet_association_us_east_1a" {
  subnet_id      = aws_subnet.subnet-vpc-eks-us-east-1a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Subnet em us-east-1b
resource "aws_subnet" "subnet-vpc-eks-us-east-1b" {
  vpc_id     = aws_vpc.vpc-eks.id
  cidr_block = cidrsubnet(aws_vpc.vpc-eks.cidr_block, 8, 1)
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-subnet-us-east-1b"
  }
}

# Associar a Tabela de Rotas à Subnet us-east-1b
resource "aws_route_table_association" "subnet_association_us_east_1b" {
  subnet_id      = aws_subnet.subnet-vpc-eks-us-east-1b.id
  route_table_id = aws_route_table.public_route_table.id
}

# EKS

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet-vpc-eks-us-east-1a.id, aws_subnet.subnet-vpc-eks-us-east-1b.id]
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.worker_role.arn
  subnet_ids      = [aws_subnet.subnet-vpc-eks-us-east-1a.id, aws_subnet.subnet-vpc-eks-us-east-1b.id]

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  instance_types = [var.instance_type]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}