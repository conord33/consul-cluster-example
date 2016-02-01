output "consul_server_instance_ips" {
  value = "${join(" ", google_compute_instance.consul-server.*.network_interface.0.access_config.0.nat_ip)}"
}

output "consul_server_pool_public_ip" {
  value = "${google_compute_forwarding_rule.default.ip_address}"
}

output "consul_client_instance_ips" {
  value = "${join(" ", google_compute_instance.consul-client.*.network_interface.0.access_config.0.nat_ip)}"
}
