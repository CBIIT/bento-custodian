resource "google_vpc_access_connector" "connector" {
  name          = "${var.stack_name}-${var.env}-vpc-cxt"
  region        = var.gcp_region
  ip_cidr_range = var.connector_network
  network       = google_compute_network.vpc.name
}

resource "google_cloud_run_service" "frontend" {
  name     = "${var.stack_name}-cloudrun-frontend"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project}/bento-frontend:latest"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
 depends_on = [google_compute_instance.bastion]
}

resource "google_cloud_run_service" "backend" {
  name     = "${var.stack_name}-cloudrun-backend"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project}/bento-backend:latest"
        resources {
          limits = {
            memory = "512M"
          }
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [google_compute_instance.bastion]
}

data "google_iam_policy" "all_users" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "cloudrun_frontend_noauth" {
  location    = google_cloud_run_service.frontend.location
  project     = google_cloud_run_service.frontend.project
  service     = google_cloud_run_service.frontend.name

  policy_data = data.google_iam_policy.all_users.policy_data
}
resource "google_cloud_run_service_iam_policy" "cloudrun_backend_noauth" {
  location    = google_cloud_run_service.backend.location
  project     = google_cloud_run_service.backend.project
  service     = google_cloud_run_service.backend.name

  policy_data = data.google_iam_policy.all_users.policy_data
}

