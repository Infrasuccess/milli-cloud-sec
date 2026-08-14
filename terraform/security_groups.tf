resource "aws_security_group" "target_sg" {
  name        = "${var.project_name}-${var.environment}-target-sg"
  description = "Target SG for vulnerable app lab"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-target-sg"
  }

  ingress {
    description = "HTTP for DVWA / DAST target"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  ingress {
    description = "HTTPS (optional)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-default-sg"
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "scanner_sg" {
  name        = "${var.project_name}-${var.environment}-scanner-sg"
  description = "Scanner/jump host SG"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-scanner-sg"
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "target_ssh_desktop" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.target_sg.id
  description       = "Desktop"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "192.168.1.100/32"
}

resource "aws_vpc_security_group_ingress_rule" "target_ssh_macbook" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.target_sg.id
  description       = "Macbook"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "192.168.1.234/32"
}

resource "aws_vpc_security_group_ingress_rule" "scanner_ssh_desktop" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.scanner_sg.id
  description       = "Desktop"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "192.168.1.100/32"
}

resource "aws_vpc_security_group_ingress_rule" "scanner_ssh_macbook" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.scanner_sg.id
  description       = "Macbook"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "192.168.1.234/32"
}
