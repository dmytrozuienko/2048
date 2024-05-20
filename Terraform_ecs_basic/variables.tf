variable "region" {
    description = "AWS Region"
    default     = "us-east-1"
}


variable "app2048_domain_name" {
  type    = string
  default = "app2048.com"
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


#variable "health_check_path" {
#  description = "Path healthy check"
#}