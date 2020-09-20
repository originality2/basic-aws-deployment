locals {
  app_name   = "hello-world"
  cluster_id = "arn:aws:ecs:ap-southeast-2:678727778487:cluster/app-cluster"
}

resource "aws_ecs_task_definition" "basic_app_task" {
  family                = "${local.app_name}-task"
  container_definitions = file("task-definitions/${local.app_name}-service.json")
  network_mode          = "awsvpc"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "basic_app_service" {
  name            = "${local.app_name}-service"                    
  cluster         = local.cluster_id             
  task_definition = aws_ecs_task_definition.basic_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.basic_app_task.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, 
                        aws_default_subnet.default_subnet_b.id, 
                        aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true   
    security_groups  = [aws_security_group.service_security_group.id]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  health_check {
    matcher = "200,301,302"
    path = "/"
  }

   depends_on = [aws_alb.application_load_balancer]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
