#provider
provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}
provider "google-beta" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_container_registry" "gcr" {
  project  = var.gcp_project
  location = "US"
}

resource "google_storage_bucket_iam_member" "bucket_iam" {
  bucket = google_container_registry.gcr.id
  role = "roles/storage.admin"
  member = "serviceAccount:${data.google_service_account.service_account.email}"
}


//#service account
//
//resource "google_service_account" "service_account" {
//  account_id = "${var.cluster_name}-bento-gke-sa"
//  display_name = "${var.cluster_name}-bento-gke-sa"
//}
//
//resource "google_project_iam_member" "iam_member" {
//  for_each = var.iam_roles
//  project = var.gcp_project
//  role = each.value
//  member = "serviceAccount:${google_service_account.service_account.email}"
//}
//
//
//resource "google_project_service" "project" {
//  for_each = var.project_services
//  project = data.google_projects.bento_demo.projects[0].project_id
//  service = each.value
//  disable_dependent_services = true
//}