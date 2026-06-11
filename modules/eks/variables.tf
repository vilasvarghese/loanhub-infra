variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for nodes and control plane"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_desired" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_min" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}
