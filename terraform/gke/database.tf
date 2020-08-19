data "google_compute_subnetwork" "db_network" {
  name   = "${var.stack_name}-${var.gcp_region}-${var.env}-db-network"
  region = var.gcp_region
  depends_on = [google_compute_subnetwork.subnet]
}

resource "google_compute_instance" "neo4j" {
  name         = "${var.stack_name}-${var.env}-database"
  machine_type = var.machine_type
  zone         =  "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }
  metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.public_ssh_key}")}"
  }
  metadata_startup_script = <<SCRIPT
          set -ex
          cd /tmp
          rm -rf bento-custodian || true
          yum -y install epel-release
          yum -y install wget git python-setuptools python-pip
          pip install ansible==2.8.0 boto boto3 botocore
          git clone https://github.com/CBIIT/bento-custodian
          cd bento-custodian/ansible
          ansible-playbook neo4j.yml -e env="${var.env}"
          systemctl restart neo4j
        SCRIPT

  network_interface {
    subnetwork = data.google_compute_subnetwork.db_network.name
  }
  tags = ["db"]
}