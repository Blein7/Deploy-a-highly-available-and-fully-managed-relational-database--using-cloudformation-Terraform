resource "aws_security_group" "web" {
  name_prefix = "${var.environment_name}-web-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-web-sg"
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment_name}-web-lt"
  image_id      = "ami-0230bd60aa48260c6" # Amazon Linux 2023
  instance_type = var.instance_type

  network_interface {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd amazon-efs-utils
              systemctl start httpd
              systemctl enable httpd
              
              # Mount EFS
              mkdir -p /mnt/efs
              mount -t efs ${var.efs_id}:/ /mnt/efs
              echo "${var.efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment_name}-web-server"
    }
  }
}

resource "aws_lb" "web" {
  name               = "${var.environment_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets           = var.public_subnet_ids

  tags = {
    Name = "${var.environment_name}-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.environment_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    timeout            = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port             = 80
  protocol         = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.environment_name}-asg"
  desired_capacity    = 2
  max_size           = 4
  min_size           = 2
  target_group_arns  = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type  = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment_name}-web-server"
    propagate_at_launch = true
  }
}
