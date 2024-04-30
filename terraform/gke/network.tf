# VPC
resource "google_compute_network" "vpc" {
  name = "${var.stack_name}-network"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}

#Subnets
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets
  name          = "${var.stack_name}-${var.gcp_region}-${var.env}-${each.key}"
  region        = var.gcp_region
  private_ip_google_access = true
  network       = google_compute_network.vpc.name
  ip_cidr_range = each.value
}

resource "google_compute_address" "nat_ips" {
  for_each = var.subnets
  name = "${each.key}-nat-ip"
  project = var.gcp_project
  region = var.gcp_region
}

resource "google_compute_router" "router" {
  name = "${var.stack_name}-nat-router"
  network = google_compute_network.vpc.self_link
}

resource "google_compute_router_nat" "nat" {
  name = "${var.stack_name}-nat-gateway"
  router = google_compute_router.router.name
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ for ip in google_compute_address.nat_ips:
          ip.self_link
  ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [google_compute_address.nat_ips]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${var.stack_name}-allow-internal"
  network = google_compute_network.vpc.self_link
  allow {
    protocol = local.icmp_protocol
  }
  allow {
    protocol = local.tcp_protocol
    ports    = ["0-65535"]
  }
  allow {
    protocol = local.udp_protocol
    ports    = ["0-65535"]
  }
  source_ranges = values(var.subnets)
}

resource "google_compute_firewall" "allow-ssh-to-bastion" {
  name    = "${var.stack_name}-${var.env}-allow-ssh-to-bastion"
  project = var.gcp_project
  network = google_compute_network.vpc.name

  allow {
    protocol = local.tcp_protocol
    ports    = [local.ssh_port]
  }
  source_ranges = [local.all_ips]

  target_tags = ["bastion"]
}

resource "google_compute_firewall" "allow-ssh-from-bastion-to-db" {
  name               = "${var.stack_name}-${var.env}-allow-ssh-from-bastion-to-db"
  project = var.gcp_project
  network = google_compute_network.vpc.name
  direction          = "EGRESS"

  allow {
    protocol = local.tcp_protocol
    ports    = [local.ssh_port,local.neo4j_https,local.neo4j_http,local.neo4j_bolts]
  }

  target_tags        = ["db"]
}

resource "google_compute_firewall" "allow-ssh-to-db-from-bastion" {
  name          = "${var.stack_name}-${var.env}-allow-ssh-to-db-from-bastion"
  project = var.gcp_project
  network = google_compute_network.vpc.name
  direction     = "INGRESS"

  allow {
    protocol = local.tcp_protocol
    ports    = [local.ssh_port,local.neo4j_https,local.neo4j_http,local.neo4j_bolts]
  }
  source_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow_neo4j_http" {
  name          = "${var.stack_name}-allow-neo4j-http"
  project = var.gcp_project
  network = google_compute_network.vpc.name
  direction          = "EGRESS"
  allow {
    protocol = local.tcp_protocol
    ports    = [local.neo4j_http]
  }
  target_tags = ["db"]
}

resource "google_compute_firewall" "allow-pod-db" {
  name    = "${var.stack_name}-allow-neo4j-to-db"
  network = google_compute_network.vpc.name
  direction     = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [local.neo4j_http]
  }
  source_ranges = ["10.8.0.0/28"]
}
