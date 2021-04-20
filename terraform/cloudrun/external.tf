data "external" "neo4j_bearer" {
  program = ["bash", "${path.module}/password.sh"]

  query = {
    neo4j_password = var.db_password
  }
}
