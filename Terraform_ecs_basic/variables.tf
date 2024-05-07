variable "region" {
    default     = "us-east-1"
    description = "AWS Region"
}


variable "vpc_cidr" {
    default     = "10.0.0.0/16"
    description = "VPC CIDR Block"
}


variable "private_subnets" {
    description = "A list of private subnets inside the VPC"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "public_subnets" {
    description = "A list of private subnets inside the VPC"
    type        = list(string)
    default     = ["10.0.3.0/24", "10.0.3.0/24"]
}


variable "availability_zones" {
    description = "A list of availability zones names or ids in the region"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b"]
}


variable "name" {
    default = "app2048"
    description = "Name of the project"
}


variable "environment" {
    default = "httpd"
    description = "Environment"
}


variable "container_port" {
    description = "Exposed container port"
    default = "80"
}


variable "tsl_certificate_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  default     = "arn:aws:acm:us-east-1:905418075806:certificate/dc7da837-b9f3-4cd9-b540-4c4717dcb5d6"
}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. /status"
}
