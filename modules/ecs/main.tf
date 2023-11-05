# Security group
## Application Loadbalancer's alb
resource "aws_security_group" "alb" {
  name   = "nick-sg-alb"
  vpc_id = var.vpc_instance.id
  depends_on = [var.vpc_instance]
 
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

## Application Loadbalancer's alb
resource "aws_security_group" "tg" {
  name   = "nick-sg-tg"
  vpc_id = var.vpc_instance.id
  depends_on = [var.vpc_instance]
 
  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
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
#############################################

# Iam role
## ECS's task role
resource "aws_iam_role" "nick_ecs_task_role" {
  name = "nick-ecsTaskRole"
 
  assume_role_policy = jsonencode({
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
  }) 
}

resource "aws_iam_policy" "nick_ecs_task_role_policy" {
  name        = "nick-task-role-policy"
  description = "Policy that allows attach to task role"
 
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Sid": "STSassumeRole",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nick_ecs_task_role_policy_attachment" {
  role       = aws_iam_role.nick_ecs_task_role.name
  policy_arn = aws_iam_policy.nick_ecs_task_role_policy.arn
}

## ECS's executor task role
resource "aws_iam_role" "nick_ecs_task_execution_role" {
  name = "nick-ecsTaskExecutionRole"
 
  assume_role_policy = jsonencode({
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
  }) 
}
 
resource "aws_iam_role_policy_attachment" "nick_ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.nick_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#############################################

# Cluster
resource "aws_ecs_cluster" "nick_ecs_cluster" {
  name = "nick-ecs-cluster"
}
#############################################

# Task definition
resource "aws_ecs_task_definition" "nick_httpd_task" {
  network_mode             = "awsvpc"
  family = "nick-httpd-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.nick_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.nick_ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = "nick-container"
    image       = "httpd:2.4"
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
  }])
}
#############################################

# Application Load balancer
resource "aws_lb" "nick_ecs_alb" {
 name               = "ecs-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.alb.id]
 subnets            = [var.vpc_public_subnet.id, var.vpc_public_subnet_1.id]
 depends_on = [var.vpc_public_subnet, var.vpc_public_subnet_1]

 tags = {
   Name = "ecs-alb"
 }
}

# Target Group
resource "aws_alb_target_group" "nick_target_group" {
  name        = "nick-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_instance.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

# Application Loadbalancer Listener
## HTTP
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.nick_ecs_alb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.nick_target_group.id
    type             = "forward"
  }
}
#############################################

# Service discovery
resource "aws_service_discovery_private_dns_namespace" "service_discovery_dns" {
  name = "nick.com"
  description = "dns for ECS's service"
  vpc = var.vpc_instance.id
}

resource "aws_service_discovery_service" "frontend" {
  name = "frontend"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery_dns.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}

#############################################

# ECS's Services
resource "aws_ecs_service" "nick_service" {
 name                               = "nick-service"
 cluster                            = aws_ecs_cluster.nick_ecs_cluster.id
 task_definition                    = aws_ecs_task_definition.nick_httpd_task.arn
 desired_count                      = 1
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 depends_on = [aws_service_discovery_service.frontend]
 
 network_configuration {
   security_groups  = [aws_security_group.tg.id]
   subnets          = [var.vpc_public_subnet.id]
   assign_public_ip = true
 }
 
  service_registries {
    registry_arn = aws_service_discovery_service.frontend.arn
  }

 load_balancer {
   target_group_arn = aws_alb_target_group.nick_target_group.id
   container_name   = "nick-container"
   container_port   = 80
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}