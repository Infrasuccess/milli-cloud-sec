resource "aws_instance" "target" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.target_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-target-root"
    Role = "dast-target"
  }

  user_data = templatefile("${path.module}/user_data_target.sh.tpl", {
    aws_region = var.aws_region
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-target"
    Role = "dast-target"
  }
}

resource "aws_instance" "scanner" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.scanner_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-scanner-root"
    Role = "security-scanner"
  }

  user_data = templatefile("${path.module}/user_data_scanner.sh.tpl", {
    aws_region = var.aws_region
    target_ip  = aws_instance.target.public_ip
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-scanner"
    Role = "security-scanner"
  }
}
