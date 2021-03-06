
 resource "local_file" "init_script" {
   content = templatefile("${path.module}/templates/startup.tpl",
   {
     gcp_project = var.gcp_project,
     gcp_auth_file = var.gcp_auth_file,
     neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
     neo4j_password = var.db_password,
     backend_repo = var.backend_repo,
     frontend_repo = var.frontend_repo,
     gcp_region = var.gcp_region,
     stack_name = var.stack_name
     env = var.env,
     image_tag = var.image_tag,
     backend_url = google_cloud_run_service.backend.status[0].url,
     connector_name = google_vpc_access_connector.connector.name,
     frontend_version = var.frontend_version,
     backend_version = var.backend_version
   })
   filename = "${path.module}/bastion.sh"
   depends_on = [google_vpc_access_connector.connector]
 }

 resource "local_file" "push_image" {
   content = templatefile("${path.module}/templates/push_image.tpl",
   {
     gcp_project = var.gcp_project,
     gcp_region = var.gcp_region,
     env = var.env,
     gcp_auth_file = var.gcp_auth_file,
   })
   filename = "${path.module}/push.sh"
 }

 resource "local_file" "frontend_service" {
   content = templatefile("${path.module}/templates/frontend.tpl",
   {
     gcp_project = var.gcp_project,
     gcp_region = var.gcp_region,
     stack_name = var.stack_name,
     image_tag = var.image_tag,
     gcp_region = var.gcp_region,
     env = var.env,
     backend_url = google_cloud_run_service.backend.status[0].url,
     release_tag = var.image_tag,
   })
   filename = "${path.module}/frontend_service.yaml"
 }

 resource "local_file" "backend_service" {
   content = templatefile("${path.module}/templates/backend.tpl",
   {
     gcp_project = var.gcp_project,
     gcp_region = var.gcp_region,
     stack_name = var.stack_name,
     connector_name = google_vpc_access_connector.connector.name
     image_tag = var.image_tag,
     gcp_region = var.gcp_region,
     env = var.env,
     neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
     neo4j_bearer = "Basic ${base64sha256(join(":",["neo4j",var.db_password]))}",
   })
   filename = "${path.module}/backend_service.yaml"
   depends_on = [google_vpc_access_connector.connector]
 }

resource "local_file" "private_key" {
  content = tls_private_key.privkey.private_key_pem
  file_permission = "0600"
  filename = "${path.module}/ansible/ssh_private_key.pem"
}

resource "local_file" "ansible_hosts" {
  content = templatefile("${path.module}/templates/hosts.tpl",
  {
    bastion_ip = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
    ssh_user = var.ssh_user
    key_path = local_file.private_key.filename
  }
  )
  filename = "${path.module}/ansible/hosts"
}

resource "local_file" "ansible_vars" {
  content = templatefile("${path.module}/templates/vars.tpl",
  {
    region = var.gcp_region
    property_filename = var.property_filename
    neo4j_password = var.db_password
    stack_name = var.stack_name
    bearer = "Basic ${base64sha256(join(":",["neo4j",var.db_password]))}"
    backend_repo = var.backend_repo
    frontend_repo = var.frontend_repo
    dataset = var.dataset
    data_repo = var.data_repo
    neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip
    gcp_project = var.gcp_project
    model_file_name = var.model_file_name
    backend_url = google_cloud_run_service.backend.status[0].url
    connector_name = google_vpc_access_connector.connector.name
  }
  )
  filename = "../../ansible/vars.yaml"
}

 resource "local_file" "db_loader" {
   content = templatefile("${path.module}/templates/dataloader.tpl",
   {
     neo4j_ip = google_compute_instance.neo4j.network_interface.0.network_ip,
     neo4j_password = var.db_password,
     data_repo = var.data_repo,
   })
   filename = "${path.module}/loader.sh"
 }