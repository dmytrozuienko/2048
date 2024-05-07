variable "region" {
    description = "AWS Region"
    default     = "us-east-1"
}


variable "vpc_cidr" {
    description = "VPC CIDR Block"
    default     = "10.0.0.0/16"
}


variable "private_subnets" {
    description = "List of private subnets"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "public_subnets" {
    description = "List of public subnets"
    type        = list(string)
    default     = ["10.0.3.0/24", "10.0.3.0/24"]
}


variable "availability_zones" {
    description = "List of availability zones"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b"]
}


variable "name" {
    description = "Name of the project"
    default = "app2048"
}


variable "environment" {
    description = "Environment"
    default = "httpd"
}


variable "container_port" {
    description = "Exposed container port"
    default = "80"
}


variable "tsl_certificate_arn" {
  description = "ARN of certificate that ALB uses for https"
  default     = "arn:aws:acm:us-east-1:905418075806:certificate/dc7da837-b9f3-4cd9-b540-4c4717dcb5d6"
}

variable "health_check_path" {
  description = "Path healthy check"
}
