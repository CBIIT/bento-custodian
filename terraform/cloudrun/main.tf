#provider
provider "google" {
  project     = var.gcp_project
  credentials = file("${path.module}/${var.gcp_auth_file}")
  region      = var.gcp_region
}
provider "google-beta" {
  project = var.gcp_project
  credentials = file("${path.module}/${var.gcp_auth_file}")
  region  = var.gcp_region
}

resource "tls_private_key" "privkey" {
  algorithm = "RSA"
  rsa_bits = 2048
}

//resource "google_container_registry" "gcr" {
//  project  = var.gcp_project
//  location = "US"
//}

//resource "google_storage_bucket_iam_member" "bucket_iam" {
//  bucket = google_container_registry.gcr.id
//  role = "roles/storage.admin"
//  member = "serviceAccount:${data.google_service_account.service_account.email}"
//}

resource "google_artifact_registry_repository" "repo" {
  provider = google-beta

  location = var.gcp_region
  repository_id = var.env
  format = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "registry_iam" {
  provider = google-beta

  location = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name
  role   = "roles/artifactregistry.admin"
  member = "serviceAccount:${data.google_service_account.service_account.email}"
}
