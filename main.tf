terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.resource_name_pattern}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.resource_name_pattern}-igw"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.24.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "${var.resource_name_pattern}-public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.24.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "${var.resource_name_pattern}-public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.24.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "${var.resource_name_pattern}-private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.24.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "${var.resource_name_pattern}-private_subnet_a"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.resource_name_pattern}-public_rt"
  }
}

resource "aws_route_table_association" "public_rt_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.resource_name_pattern}-private_rt"
  }
}

resource "aws_route_table_association" "private_rt_subnet_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_subnet_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "MyDB" {
  name = "MyDB"
  tags = {
    Name = "MyDB"
  }
  description = "access to Database instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "WebApp" {
  name = "WebApp"
  tags = {
    Name = "WebApp"
  }
  description = "access to Webapp instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "LoadBalancer" {
  name = "LoadBalancer"
  tags = {
    Name = "LoadBalancer"
  }
  description = "access to loadbalancer instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_DB" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.MyDB.id
  source_security_group_id = aws_security_group.WebApp.id
}


resource "aws_security_group_rule" "egress_DB" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.MyDB.id
}

resource "aws_security_group_rule" "ingress_WebApp" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.WebApp.id
  source_security_group_id = aws_security_group.LoadBalancer.id
}

resource "aws_security_group_rule" "egress_WebApp" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.WebApp.id
  source_security_group_id = aws_security_group.MyDB.id
}

resource "aws_security_group_rule" "egress_WebApp2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.WebApp.id
}

resource "aws_security_group_rule" "ingress_LoadBalancer" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.LoadBalancer.id
}

resource "aws_security_group_rule" "egress_LoadBalancer" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.LoadBalancer.id
  source_security_group_id = aws_security_group.WebApp.id
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.keypair_name
  public_key = file(var.keypair_path)
}

resource "aws_db_subnet_group" "mysql-ddbb-sg" {
  name       = "subnet group database"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql_ddbb" {
  allocated_storage            = 20
  storage_type                 = "gp2"
  storage_encrypted            = false
  max_allocated_storage        = 0
  engine                       = "mysql"
  engine_version               = "8.0.17"
  instance_class               = "db.t2.micro"
  port                         = 3306
  name                         = var.ddbb.dbname
  username                     = var.ddbb.username
  password                     = var.ddbb.password
  skip_final_snapshot          = true
  db_subnet_group_name         = aws_db_subnet_group.mysql-ddbb-sg.name
  publicly_accessible          = true
  performance_insights_enabled = false
  deletion_protection          = false
  vpc_security_group_ids       = [aws_security_group.MyDB.id]
  apply_immediately            = true
  multi_az                     = false
  backup_retention_period      = 0

  depends_on = [
    aws_db_subnet_group.mysql-ddbb-sg
  ]
}

# Configuring secret manager
resource "aws_secretsmanager_secret" "rtb-db-secret" {
  name = "rtb-db-secret"
  depends_on = [
    aws_db_instance.mysql_ddbb
  ]
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.rtb-db-secret.id
  secret_string = jsonencode({

    "username" : var.ddbb.username,
    "password" : var.ddbb.password,
    "host" : aws_db_instance.mysql_ddbb.address,
    "db" : var.ddbb.dbname
  })
  depends_on = [
    aws_secretsmanager_secret.rtb-db-secret
  ]
}

# IAM policy to get secret value
data "aws_iam_policy_document" "secret_value" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.rtb-db-secret.arn]
  }

  depends_on = [
    aws_secretsmanager_secret.rtb-db-secret
  ]
}

# Secret policy creation
resource "aws_iam_policy" "secret_policy" {
  name        = "secret_policy"
  description = "Database connection details"
  policy      = data.aws_iam_policy_document.secret_value.json
}

# Data role
data "aws_iam_policy_document" "role_value" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role creation
resource "aws_iam_role" "role_access_secret" {
  name               = "role_access_secret"
  assume_role_policy = data.aws_iam_policy_document.role_value.json
}

# Policy attachment to role
resource "aws_iam_policy_attachment" "policy_attach" {
  name       = "policy_attach"
  roles      = [aws_iam_role.role_access_secret.id]
  policy_arn = aws_iam_policy.secret_policy.arn
  depends_on = [aws_iam_role.role_access_secret, aws_iam_policy.secret_policy]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name       = "instance_profile"
  role       = aws_iam_role.role_access_secret.name
  depends_on = [aws_iam_policy_attachment.policy_attach]

}

resource "aws_lb" "loadbalancer_EC2" {
  name               = "lb-EC2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LoadBalancer.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  depends_on = [aws_subnet.public_subnet_a, aws_subnet.public_subnet_b, aws_security_group.LoadBalancer]

}

resource "aws_lb_target_group" "lb_tg" {
  name        = "lb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/api/utils/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200" # has to be HTTP 200 or fails
  }

  depends_on = [aws_lb.loadbalancer_EC2]

}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.loadbalancer_EC2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

  depends_on = [aws_lb_target_group.lb_tg, aws_lb.loadbalancer_EC2]

}

# Launch template creation

resource "aws_launch_template" "webapp_template" {
  name                    = "webapp_template"
  image_id                = var.instance_ami
  instance_type           = var.instance_type
  key_name                = aws_key_pair.key_pair.key_name
  disable_api_termination = false
  user_data               = filebase64("./webapp.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.WebApp.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name

  }

  tags = {
    Name = "instance_profile"
  }

  depends_on = [aws_security_group.WebApp, aws_iam_instance_profile.instance_profile, aws_key_pair.key_pair]
}

resource "aws_autoscaling_group" "autoscalingEC2" {
  name                = "autoscaling EC2 instance"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  launch_template {
    id      = aws_launch_template.webapp_template.id
    version = "$Latest"
  }

  tag {
    key                 = "name"
    value               = "autoscalingEC2"
    propagate_at_launch = true
  }

  depends_on = [aws_subnet.public_subnet_a, aws_subnet.public_subnet_b, aws_launch_template.webapp_template,
  aws_lb_target_group.lb_tg]
}

