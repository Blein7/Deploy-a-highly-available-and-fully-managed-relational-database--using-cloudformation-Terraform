variable "environment_name" {
  description = "Environment name that will be prefixed to resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "web_server_sg_id" {
  description = "Security group ID of the web servers"
  type        = string
}
