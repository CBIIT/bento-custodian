output "bastion_host_private_ip" {
  value = google_compute_instance.bastion.network_interface.0.network_ip
}
output "bastion_host_public_ip" {
  value = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}
output "db_private_ip" {
  value = google_compute_instance.neo4j.network_interface.0.network_ip
}

output "frontend_url" {
  value = google_cloud_run_service.frontend.status[0].url
}
output "backend_url" {
  value = google_cloud_run_service.backend.status[0].url
}
output "service_id" {
  value = data.google_service_account.service_account.email
}