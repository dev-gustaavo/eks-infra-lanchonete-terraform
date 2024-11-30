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