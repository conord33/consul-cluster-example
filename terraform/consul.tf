provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file(var.account_file_path)}"
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
      "echo ${google_compute_instance.consul-server.0.network_interface.0.address} > /tmp/consul-server-addr"
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

/*
resource "google_compute_instance" "consul-client" {
  count = 1

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
    sshKeys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}
*/
