provider "aws" {
    region = "${var.region}"
}


resource "aws_vpc" "app2048-vpc" {
    cidr_block              = "${var.vpc_cidr}"
    enable_dns_hostnames    = true
}


resource "aws_internet_gateway" "app2048-igw" {
    vpc_id = "${aws_vpc.app2048-vpc.id}"
}


resource "aws_subnet" "private-subnet" {
    vpc_id              = aws_vpc.app2048-vpc.id
    cidr_block          = element(var.private_subnets, count.index)
    availability_zone   = element(var.availability_zones, count.index)
    count               = length(var.private_subnets)
}


resource "aws_subnet" "public-subnet" {
    vpc_id                  = aws_vpc.app2048-vpc.id
    cidr_block              = element(var.public_subnets, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    count                   = length(var.public_subnets)
}


resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.app2048-vpc.id
}


resource "aws_route" "public-igw-route" {
    route_table_id          = aws_route_table.public-route-table.id
    gateway_id              = aws_internet_gateway.app2048-igw.id
    destination_cidr_block  = "0.0.0.0/0"
}


resource "aws_route_table_association" "public-subnet-association" {
    count           = length(var.public_subnets)
    subnet_id       = element(aws_subnet.public-subnet.*.id, count.index)
    route_table_id  = aws_route_table.public-route-table.id
}


resource "aws_nat_gateway" "nat-gw" {
    count           = length(var.private_subnets)
    allocation_id   = element(aws_eip.eip-for-nat-gw.*.id, count.index)
    subnet_id       = element(aws_subnet.public-subnet.*.id, count.index)
    depends_on      = [aws_eip.eip-for-nat-gw]
}


resource "aws_eip" "eip-for-nat-gw" {
    domain = "vpc"
    count = length(var.private_subnets)
}


resource "aws_route_table" "private-route-table" {
    count   = length(var.private_subnets)
    vpc_id  = aws_vpc.app2048-vpc.id
}


resource "aws_route" "private-nat-gw-route" {
    count                   = length(compact(var.private_subnets))
    route_table_id          = element(aws_route_table.private-route-table.*.id, count.index)
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = element(aws_nat_gateway.nat-gw.*.id, count.index)
}


resource "aws_route_table_association" "private-subnet-association" {
    count           = length(var.private_subnets)
    subnet_id       = element(aws_subnet.private-subnet.*.id, count.index)
    route_table_id  = element(aws_route_table.private-route-table.*.id, count.index)
}


resource "aws_security_group" "alb-sg" {
    name   = "${var.name}-alb-sg-${var.environment}"
    vpc_id = aws_vpc.app2048-vpc.id
 
    ingress {
        protocol         = "tcp"
        from_port        = 80
        to_port          = 80
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
 
    ingress {
        protocol         = "tcp"
        from_port        = 443
        to_port          = 443
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
 
    egress {
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}


resource "aws_security_group" "ecs-tasks-sg" {
    name   = "${var.name}-task-sg-${var.environment}"
    vpc_id = aws_vpc.app2048-vpc.id
 
    ingress {
        protocol         = "tcp"
        from_port        = var.container_port
        to_port          = var.container_port
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
 
    egress {
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}


# ECS


#resource "aws_ecr_repository" "app2048-ecr" {
#  name                 = "${var.name}-${var.environment}"
#  image_tag_mutability = "MUTABLE"
#}


#resource "aws_ecr_lifecycle_policy" "ecr-lifecycle-policy" {
#  repository = aws_ecr_repository.app2048-ecr.name
# 
#  policy = jsonencode({
#   rules = [{
#     rulePriority = 1
#     description  = "keep last 10 images"
#     action       = {
#       type = "expire"
#     }
#     selection     = {
#       tagStatus   = "any"
#       countType   = "imageCountMoreThan"
#       countNumber = 10
#     }
#   }]
#  })
#}


resource "aws_ecs_cluster" "fargate-cluster" {
    name = "${var.name}-cluster-${var.environment}"
}


resource "aws_ecs_task_definition" "task-definition" {
    family = "app2048"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu         = 512
    memory      = 1024
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn
    container_definitions = jsonencode([{
            name        = "app2048_httpd"
            image       = "905418075806.dkr.ecr.us-east-1.amazonaws.com/app2048_httpd"
            essential   = true
            portMappings = [{
                protocol      = "tcp"
                containerPort = var.container_port
                hostPort      = var.container_port
            }]
    }])
}


resource "aws_iam_role" "ecs_task_role" {
    name = "${var.name}-ecsTaskRole"

    assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}


resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ECS-Task-Execution-Role"
    
    assume_role_policy  = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_service" "ecs-service" {
    name                               = "${var.name}_${var.environment}"
    cluster                            = aws_ecs_cluster.fargate-cluster.id
    task_definition                    = aws_ecs_task_definition.task-definition.arn
    desired_count                      = 1
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent         = 200
    launch_type                        = "FARGATE"
    scheduling_strategy                = "REPLICA"
 
    network_configuration {
      security_groups  = [aws_security_group.ecs-tasks-sg.id]
      subnets          = aws_subnet.private-subnet.*.id
      assign_public_ip = false
    }
 
    load_balancer {
      target_group_arn = aws_alb_target_group.alb-target-group.arn
      container_name   = "${var.name}_${var.environment}"
      container_port   = var.container_port
    }
 
    lifecycle {
        ignore_changes = [task_definition, desired_count]
    }
}


resource "aws_lb" "lb" {
    name               = "${var.name}-alb-${var.environment}"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb-sg.id]
    subnets            = aws_subnet.private-subnet.*.id
 
    enable_deletion_protection = false
}

 
resource "aws_alb_target_group" "alb-target-group" {
    name        = "${var.name}-tg-${var.environment}"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.app2048-vpc.id
    target_type = "ip"
 
    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
#        path                = var.health_check_path
        unhealthy_threshold = "2"
    }
}


resource "aws_alb_listener" "alb-http-listener" {
    load_balancer_arn = aws_lb.lb.id
    port              = 80
    protocol          = "HTTP"
 
#    default_action {
#        type = "redirect"
# 
#        redirect {
#            port        = 443
#            protocol    = "HTTPS"
#            status_code = "HTTP_301"
#        }
#   }

    default_action {
        target_group_arn = aws_alb_target_group.alb-target-group.id
        type             = "forward"
    }
}


#resource "aws_alb_listener" "alb-https-listener" {
#    load_balancer_arn = aws_lb.lb.id
#    port              = 443
#    protocol          = "HTTPS"
# 
#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = var.tsl_certificate_arn
# 
#    default_action {
#        target_group_arn = aws_alb_target_group.alb-target-group.id
#        type             = "forward"
#    }
#}


resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = 4
    min_capacity       = 1
    resource_id        = "service/${aws_ecs_cluster.fargate-cluster.name}/${aws_ecs_service.ecs-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
    name               = "memory-autoscaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
 
        target_value = 80
    }
}
 

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
    name               = "cpu-autoscaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
 
        target_value = 60
    }
}


# Route53

#resource "aws_route53_record" "app2048-route53" {
#    zone_id = aws_route53_zone.primary.zone.id
#    name = "app2048.com"
#    type = "A"
#    ttl = 300
#    records = [aws_lb.lb.dns_name]
#}