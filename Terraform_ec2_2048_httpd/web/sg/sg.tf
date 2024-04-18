variable "ingress_rules" {
    type = list(number)
    default = [ 80, 443, 22 ]
}


variable "egress_rules" {
    type = list(number)
    default = [ 80, 443, 22 ]
}


output "sg_name" {
    value = aws_security_group.web_traffic.name
}


resource "aws_security_group" "web_traffic" {
    name = "Allow HTTPS"


    dynamic "ingress" {
        iterator = port
        for_each = var.ingress_rules
        content {
        from_port = port.value
        to_port = port.value
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }

  

    dynamic "egress" {
        iterator = port
        for_each = var.egress_rules
        content {
        from_port = port.value
        to_port = port.value
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }
}
