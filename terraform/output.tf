output "instance_internal_ips" {
  value = "${join(" ", google_compute_instance.consul-server.*.network_interface.0.address)}"
}

output "instance_external_ips" {
  value = "${join(" ", google_compute_instance.consul-server.*.network_interface.0.access_config.0.nat_ip)}"
}
