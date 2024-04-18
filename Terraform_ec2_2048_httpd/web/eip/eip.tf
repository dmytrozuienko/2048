variable "instance_id" {
    type = string
}


# Cost money
resource "aws_eip" "web_server_public_ip" {
    instance = var.instance_id
    
}


output "web_server_public_ip" {
    value = aws_eip.web_server_public_ip.public_ip
}