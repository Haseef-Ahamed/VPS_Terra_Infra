output "db_endpoint" {
  value = "${docker_container.db.network_data[0].ip_address}:3306"
}