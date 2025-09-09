output "app_ips" {
  value = [for c in docker_container.app : c.network_data[0].ip_address]
}