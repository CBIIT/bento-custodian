data "google_compute_image" "image" {
  family  = "centos-7"
  project = "centos-cloud"
}
data "google_projects" "bento_demo" {
  filter = "name:${var.gcp_project}"
}
data "google_service_account" "service_account" {
  account_id = var.service_account_id
}
data "google_client_config" "config" {}