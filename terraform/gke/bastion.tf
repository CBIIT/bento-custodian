data "google_compute_subnetwork" "mgmt_network" {
  name   = "${var.stack_name}-${var.gcp_region}-${var.env}-mgmt-network"
  region = var.gcp_region
  depends_on = [google_compute_subnetwork.subnet]
}

resource "google_compute_instance" "bastion" {
  name         = "${var.stack_name}-bastion-host"
  machine_type = var.machine_type
  zone         =  "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.ssh_key}")}"
  }

  network_interface {
      subnetwork = data.google_compute_subnetwork.mgmt_network.name
    access_config {
    }
  }

  tags = ["bastion"]
}