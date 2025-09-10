terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "mysql" {
  name = "mysql:8.0"
}

resource "docker_container" "db" {
  name  = "${var.env}-db"
  image = docker_image.mysql.name

  networks_advanced {
    name = var.private_net_id
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_password}",
    "MYSQL_DATABASE=${var.db_name}",
    "MYSQL_REQUIRE_SECURE_TRANSPORT=ON"
  ]

  ports {
    internal = 3306
    external = 3307  # Free port on VPS
  }
}