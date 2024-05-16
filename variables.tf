variable "project_name" {
  description = "A unique name for your project. This will be used as part of resource names."
  default     = ""
}

variable "access_ip_range" {
  description = "The range of office IP range"
  default     = "188.163.184.166/32"
}

variable "default_security_group_id" {
  description = "Default security group ID"
  default     = ""
}

variable "cluster_primary_security_group_id" {
  description = "Kubernetes cluster security group ID"
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where kubernetes reside"
  default     = ""
}

variable "private_subnets" {
  description = "Private subnets for kubernetes configuration"
  default     = ""
}

variable "ingress_group_name" {
  description = "The ingress group name for single load balancer usage"
  default     = "external-traffic"
}

variable "repo_helmcharts_name" {
  description = "The name of the repository for Helm charts."
  default     = ""
}

variable "argocd_security_group_id" {
  description = "Additional security group"
  default     = ""
}

variable "slack_namespace" {
  description = "Additional security group"
  default     = ""
}

variable "slack_token" {
  description = "Additional security group"
  default     = ""
}

variable "skip_ecs" {
  description = "shoud be true"
  default     = true
}

variable "github_organization" {
  description = "Github organization where repositories should be created"
  default     = ""
}

variable "github_username" {
  description = "Personal github username"
}

variable "github_token" {
  description = "Personal github token"
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
}

variable "aws_region" {
  description = "AWS Region"
}

variable "db_password" {
  description = "Password for postgres"
}

variable "db_username" {
  description = "Username for postgres"
}

variable "db_name" {
  description = "DB name for postgres"
}
