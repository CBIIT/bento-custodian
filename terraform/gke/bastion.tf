data "google_compute_subnetwork" "mgmt_network" {
  name   = "${var.stack_name}-${var.gcp_region}-${var.env}-mgmt-network"
  region = var.gcp_region
  depends_on = [google_compute_subnetwork.subnet]
}

resource "local_file" "deploy_script" {
  content = templatefile("${path.module}/scripts/startup.sh",
  {
    gcp_project = var.gcp_project,
    cluster_name = google_container_cluster.gke.name
    gcp_auth_file = var.gcp_auth_file,
    neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
    neo4j_password = var.db_password
    gcp_region = var.gcp_region
  })
  filename = "${path.module}/bastion.sh"
  depends_on = [google_compute_instance.neo4j,google_container_cluster.gke]
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
    ssh-keys = "${var.ssh_user}:${file("${var.public_ssh_key}")}"
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.mgmt_network.name
    access_config {
    }
  }
  provisioner "file" {
    source = var.gcp_auth_file
    destination = "/tmp/${var.gcp_auth_file}"

    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file("${path.module}/${var.private_ssh_key}")
      agent = "false"
      host = self.network_interface.0.access_config.0.nat_ip
    }
  }
  provisioner "file" {
    source = "${path.module}/bastion.sh"
    destination = "/tmp/bastion.sh"

    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file("${path.module}/${var.private_ssh_key}")
      agent = "false"
      host = self.network_interface.0.access_config.0.nat_ip
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
      private_key =  file("${path.module}/${var.private_ssh_key}")
      agent = "false"
      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
    }
  }
  tags = ["bastion"]
  depends_on = [ google_compute_instance.neo4j,local_file.deploy_script]
}

//resource "local_file" "update" {
//  content = templatefile("${path.module}/scripts/update_script.sh",
//  {
//    gcp_project = var.gcp_project,
//    gcp_auth_file = var.gcp_auth_file,
//    neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
//    neo4j_password = var.db_password,
//    backend_url = google_cloud_run_service.backend.status[0].url,
//    tag = var.tag_name,
//  })
//  filename = "${path.module}/update.sh"
//}
//
//resource "local_file" "db_loader" {
//  content = templatefile("${path.module}/scripts/dataloader.sh",
//  {
//    neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
//    neo4j_password = var.db_password
//  })
//  filename = "${path.module}/loader.sh"
//}
//
//
//
//resource "null_resource" "update_deployment" {
//
//  provisioner "file" {
//    source = "${path.module}/frontend_service.yaml"
//    destination = "/tmp/frontend_service.yaml"
//
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  provisioner "file" {
//    source = "${path.module}/backend_service.yaml"
//    destination = "/tmp/backend_service.yaml"
//
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  provisioner "file" {
//    source = "${path.module}/update.sh"
//    destination = "/tmp/update.sh"
//
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  provisioner "remote-exec" {
//    inline = [
//      "sudo docker system prune -a -f",
//      "chmod +x /tmp/update.sh",
//      "sudo /tmp/update.sh",
//      "sudo gcloud beta run services replace /tmp/backend_service.yaml --platform managed --region  ${var.gcp_region}",
//      "sudo gcloud beta run services replace /tmp/frontend_service.yaml --platform managed --region  ${var.gcp_region}",
//    ]
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  depends_on = [google_compute_instance.bastion,local_file.update]
//}
//
//resource "null_resource" "data_loader" {
//  provisioner "file" {
//    source = "${path.module}/loader.sh"
//    destination = "/tmp/loader.sh"
//
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  provisioner "remote-exec" {
//    inline = [
//      "chmod +x /tmp/loader.sh",
//      "sudo /tmp/loader.sh",
//    ]
//    connection {
//      type = "ssh"
//      user = var.ssh_user
//      private_key =  file("${path.module}/${var.private_ssh_key}")
//      agent = "false"
//      host = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
//    }
//  }
//  depends_on = [google_compute_instance.bastion,null_resource.update_deployment]
//}
