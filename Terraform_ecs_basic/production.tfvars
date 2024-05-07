name                = "app2048"
environment         = "test"
region              = "us-east-1"
availability_zones  = ["us-east-1a", "us-east-1b"]
vpc_cidr            = "10.0.0.0/16"
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
container_port      = 80
health_check_path   = "/health"