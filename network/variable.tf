# @author Amenda Fernando
# @date 2024.11.02
# non-prod network

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "docker-ecr"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets in non prod Environment"
  type        = string
  default     = "10.1.1.0/24"
}

variable "default_tags" {
  description = "Default tags for resources"
  type        = map(string)
  default = {
    Environment = "docker-ecr"
    Project     = "CLO835"
  }
}
