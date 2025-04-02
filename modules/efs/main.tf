resource "aws_security_group" "efs" {
  name_prefix = "${var.environment_name}-efs-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.web_server_sg_id]
  }

  tags = {
    Name = "${var.environment_name}-efs-sg"
  }
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.environment_name}-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.environment_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
