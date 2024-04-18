provider "aws" {
    region = "us-east-1"
}


module "web" {
    source = "./web"
}


output "module_web_public_ip" {
    value = module.web.public_ip
}