resource "aws_security_group" "rds" {
  name_prefix = "${var.environment_name}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_server_sg_id]
  }

  tags = {
    Name = "${var.environment_name}-rds-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.environment_name}-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.db_instance_class
  allocated_storage   = 20
  storage_type        = "gp2"
  
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  
  multi_az            = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  tags = {
    Name = "${var.environment_name}-rds"
  }
}
