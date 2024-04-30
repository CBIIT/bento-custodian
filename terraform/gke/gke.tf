data "google_compute_subnetwork" "gke_network" {
  name   = "${var.stack_name}-${var.gcp_region}-${var.env}-gke-network"
  region = var.gcp_region
  depends_on = [google_compute_subnetwork.subnet]
}

# GKE cluster
resource "google_container_cluster" "gke" {
  name     = "${var.cluster_name}-${var.env}-gke"
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.subnet_range
      display_name = "all"
    }

  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.pod_range
    services_ipv4_cidr_block = var.service_range
  }
  network = google_compute_network.vpc.name
  subnetwork = data.google_compute_subnetwork.gke_network.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }

}

resource "google_container_node_pool" "dev_nodes" {
  name       = "${google_container_cluster.gke.name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.gke.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = var.stack_name
    }

    machine_type = var.machine_type
    tags         = ["gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
