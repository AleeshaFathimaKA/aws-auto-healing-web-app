
# Get the latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# EC2 Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y python3 git

    mkdir -p /opt/auto-healing-app

    git clone https://github.com/AleeshaFathimaKA/aws-auto-healing-web-app.git /opt/auto-healing-app/repository

    cp /opt/auto-healing-app/repository/app/app.py /opt/auto-healing-app/app.py
    cp /opt/auto-healing-app/repository/app/requirements.txt /opt/auto-healing-app/requirements.txt

    python3 -m venv /opt/auto-healing-app/venv
    /opt/auto-healing-app/venv/bin/pip install -r /opt/auto-healing-app/requirements.txt
    /opt/auto-healing-app/venv/bin/pip install gunicorn

    cat > /etc/systemd/system/auto-healing-app.service <<'SERVICE'
    [Unit]
    Description=Auto Healing Flask Application
    After=network-online.target
    Wants=network-online.target

    [Service]
    User=root
    WorkingDirectory=/opt/auto-healing-app
    ExecStart=/opt/auto-healing-app/venv/bin/gunicorn --bind 0.0.0.0:5000 app:app
    Restart=always
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable auto-healing-app
    systemctl start auto-healing-app
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.project_name}-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
