data "google_compute_image" "image" {
  family  = "centos-7"
  project = "centos-cloud"
}
data "google_projects" "bento_demo" {
  filter = "name:${var.gcp_project}"
}