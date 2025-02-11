variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "desired_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 3
}

variable "min_capacity" {
  default = 1
}

variable "instance_type" {
  default = "t3.medium"
}

# Variáveis para o namespace e o nome da service account
variable "namespace" {
  description = "O namespace no qual o service account será criado"
  type        = string
}

variable "service_account_name" {
  description = "O nome da service account que será criada"
  type        = string
}