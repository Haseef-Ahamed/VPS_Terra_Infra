terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "app" {
  name = "httpd:latest"
}

resource "docker_container" "app" {
  count = var.app_count
  name  = "${var.env}-app-${count.index + 1}"
  image = docker_image.app.name

  networks_advanced {
    name = var.private_net_id
  }

  ports {
  internal = 80
  external = 8081
  }

}