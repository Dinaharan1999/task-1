provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "task_sg" {
  name        = "task-sg"
  description = "Security group for task instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count                       = 2
  ami                         = "ami-0f091043d3a597335" 
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.task_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "task-instance-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              echo "Hello World..!" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF
}

resource "aws_lb_target_group" "task_tg" {
  name        = "task-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web_targets" {
  count            = 2
  target_group_arn = aws_lb_target_group.task_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_lb" "task_lb" {
  name               = "task-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.task_sg.id]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.task_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_tg.arn
  }
}
