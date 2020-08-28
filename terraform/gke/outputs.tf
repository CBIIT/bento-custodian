output "bastion_host_private_ip" {
  value = google_compute_instance.bastion.network_interface.0.network_ip
}
output "bastion_host_public_ip" {
  value = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}
output "db_private_ip" {
  value = google_compute_instance.neo4j.network_interface.0.network_ip
}

output "web_frontend_ip" {
  value = google_compute_global_address.default.address
}