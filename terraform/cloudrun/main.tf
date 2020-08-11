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

resource "local_file" "db_script" {
  content = templatefile("${path.module}/scripts/startup.sh",
  {
    gcp_project = var.gcp_project,
    gcp_auth_file = var.gcp_auth_file,
    neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
    neo4j_password = var.db_password
  })
  filename = "${path.module}/bastion.sh"
}


resource "local_file" "frontend_service" {
  content = templatefile("${path.module}/scripts/frontend.yaml",
  {
    gcp_project = var.gcp_project,
    gcp_region = var.gcp_region,
    stack_name = var.stack_name,
    tag = var.tag_name,
  })
  filename = "${path.module}/frontend_service.yaml"
}

resource "local_file" "backend_service" {
  content = templatefile("${path.module}/scripts/backend.yaml",
  {
    gcp_project = var.gcp_project,
    gcp_region = var.gcp_region,
    stack_name = var.stack_name,
    connector_name = google_vpc_access_connector.connector.name
    tag = var.tag_name,
  })
  filename = "${path.module}/backend_service.yaml"
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
