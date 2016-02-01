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

  connection {
    user = "${var.user}"
    private_key = "${var.private_key_path}"
  }

  disk {
    image = "centos-cloud/centos-6-v20160119"
  }

  provisioner "file" {
    source = "../scripts/upstart.conf"
    destination = "/tmp/upstart.conf"
  }

  provisioner "file" {
    source = "../scripts/upstart-join.conf"
    destination = "/tmp/upstart-join.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.server_count} > /tmp/consul-server-count",
      "echo ${google_compute_instance.consul-server.0.network_interface.0.address} > /tmp/consul-join-addr"
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "../scripts/install.sh",
      "../scripts/server.sh",
      "../scripts/service.sh"
    ]
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
  count = 1

  name = "consul-client"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["consul", "consul-client"]

  connection {
    user = "${var.user}"
    private_key = "${var.private_key_path}"
  }

  disk {
    image = "centos-cloud/centos-6-v20160119"
  }

  provisioner "file" {
    source = "../scripts/upstart.conf"
    destination = "/tmp/upstart.conf"
  }

  provisioner "file" {
    source = "../scripts/upstart-join.conf"
    destination = "/tmp/upstart-join.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${google_compute_forwarding_rule.default.ip_address} > /tmp/consul-join-addr"
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "../scripts/client-join.sh",
      "../scripts/install.sh",
      "../scripts/service.sh"
    ]
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
