resource "aws_instance" "web" {
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.micro"
    security_groups = [ module.sg.sg_name ]
    user_data = file("./web/server-script.sh")
    tags = {
        Name = "Web Server"
    }
}


output "public_ip" {
    value = module.eip.web_server_public_ip
}


module "eip" {
    source = "./eip"
    instance_id = aws_instance.web.id
}


module "sg" {
    source = "./sg"
}