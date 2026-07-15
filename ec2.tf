resource "aws_instance" "monitor" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  tags          = { Name = "monitor" }
  user_data = templatefile("${path.module}/scripts/monitor.sh.tftpl", {
    install_prometheus = templatefile("${path.module}/scripts/install_prometheus.sh.tftpl",
      {
        prometheus_config = templatefile("${path.module}/configs/prometheus.yml.tftpl",
          {
            node1_private_ip = aws_instance.node1.private_ip
            node2_private_ip = aws_instance.node2.private_ip
          }
        )
        prometheus_service = file("${path.module}/systemd/prometheus.service")
        cpu_alert          = file("${path.module}/configs/alerts/cpu.yml.tftpl")
        memory_alert       = file("${path.module}/configs/alerts/memory.yml.tftpl")
        disk_alert         = file("${path.module}/configs/alerts/disk.yml.tftpl")
        node_alert         = file("${path.module}/configs/alerts/node.yml.tftpl")
      }
    ),
    install_grafana = templatefile("${path.module}/scripts/install_grafana.sh.tftpl",
      {
        grafana_dashboard_provider = file("${path.module}/configs/grafana/dashboard.yml")
        grafana_dashboard = base64gzip(
          file("${path.module}/configs/grafana/monitoring-dashboard.json")
        )
        grafana_datasource = file("${path.module}/configs/grafana/datasource.yml")
      }
    ),
    install_alertmanager = templatefile("${path.module}/scripts/install_alertmanager.sh.tftpl",
      {
        alertmanager_config = templatefile("${path.module}/configs/alertmanager.yml.tftpl",
          {
            smtp_email    = var.smtp_email
            smtp_password = var.smtp_password
          }
        )
        alertmanager_service = file("${path.module}/systemd/alertmanager.service")
      }
    ),
  })
  vpc_security_group_ids = [aws_security_group.monitor_sg.id]
}

resource "aws_instance" "node1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  tags          = { Name = "node1" }
  user_data = templatefile("${path.module}/scripts/node.sh.tftpl", {
    node_exporter_service = file("${path.module}/systemd/node_exporter.service")
  })
  vpc_security_group_ids = [aws_security_group.node_sg.id]
}

resource "aws_instance" "node2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  tags          = { Name = "node2" }
  user_data = templatefile("${path.module}/scripts/node.sh.tftpl", {
    node_exporter_service = file("${path.module}/systemd/node_exporter.service")
  })
  vpc_security_group_ids = [aws_security_group.node_sg.id]
}
