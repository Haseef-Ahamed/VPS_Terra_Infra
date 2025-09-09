output "lb_access_url" {
  value = "http://194.164.151.129:8082"
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "app_ips" {
  value = module.compute.app_ips
}