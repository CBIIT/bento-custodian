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
    ssh-keys = "${var.ssh_user}:${tls_private_key.privkey.public_key_openssh}"
  }
  metadata_startup_script = <<SCRIPT
          #!/bin/bash
          set -ex
          cd /tmp
          rm -rf bento-custodian || true
          yum -y install epel-release python python-setuptools python-pip
          yum -y install wget git
          pip install --upgrade "pip < 21.0"
          pip install ansible==2.8.0
          git clone https://github.com/CBIIT/bento-custodian
          cd bento-custodian/ansible
          ansible-playbook community-neo4j.yml -e env=test
          systemctl restart neo4j
        SCRIPT

  network_interface {
    subnetwork = data.google_compute_subnetwork.db_network.name
  }
  tags = ["db"]
}

resource "null_resource" "build_image" {
  provisioner "file" {
    source = "${path.module}/bastion.sh"
    destination = "/tmp/bastion.sh"

    connection {
      type = "ssh"
      user = var.ssh_user
      //      private_key = file("${path.module}/ansible/ssh_private_key.pem")
      private_key = local.private_key
      agent = "false"
      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bastion.sh",
      "sudo /tmp/bastion.sh",
    ]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = local.private_key
      agent = "false"
      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
    }
  }
  depends_on = [google_compute_instance.bastion]
}