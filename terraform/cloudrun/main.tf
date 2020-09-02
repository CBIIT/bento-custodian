#provider
provider "google" {
  project     = var.gcp_project
  credentials = file("${path.module}/${var.gcp_auth_file}")
  region      = var.gcp_region
}
provider "google-beta" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "tls_private_key" "privkey" {
  algorithm = "RSA"
  rsa_bits = 2048
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
