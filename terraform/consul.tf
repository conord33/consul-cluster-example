provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_http_health_check" "default" {
  name = "consul-server-basic-check"
  request_path = "/v1/status/leader"
  check_interval_sec = 2
  healthy_threshold = 1
  unhealthy_threshold = 10
  timeout_sec = 2
  port = "8500"
}

resource "google_compute_target_pool" "default" {
  name = "consul-server-target-pool"
  instances = ["${google_compute_instance.consul-server.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

resource "google_compute_forwarding_rule" "default" {
  name = "consul-server-forwarding-rule"
  target = "${google_compute_target_pool.default.self_link}"
  port_range = "8500"
}

resource "google_compute_firewall" "default" {
  name = "consul-server-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["8500"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["consul-server"]
}

resource "google_compute_instance" "consul-server" {
  count = "${var.server_count}"

  name = "consul-server-${count.index}"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["consul", "consul-server"]

  disk {
    image = "centos-cloud/centos-6-v20160119"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata {
    sshKeys = "${var.user}:${file(var.public_key_path)}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

resource "google_compute_instance" "consul-client" {
  count = 2

  name = "consul-client-${count.index}"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["consul", "consul-client", "http-server"]

  disk {
    image = "centos-cloud/centos-6-v20160119"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata {
    sshKeys = "${var.user}:${file(var.public_key_path)}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

resource "null_resource" "Provision" {
  provisioner "local-exec" {
    command = <<EOF
    cd ../ansible
    ansible-playbook -i inventories/terraform.py \
      -e 'consul_cluster_addr=${google_compute_forwarding_rule.default.ip_address} consul_server_count=${var.server_count}' \
      -u ${var.user} \
      consul.yml
EOF
  }
}
