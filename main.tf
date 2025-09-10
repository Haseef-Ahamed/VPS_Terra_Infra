terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock" # Local Docker socket on VPS
}

module "network" {
  source = "./modules/network"
  env    = var.env
}

module "compute" {
  source         = "./modules/compute"
  env            = var.env
  private_net_id = module.network.private_net_id
  app_count      = var.app_count
}

module "database" {
  source         = "./modules/database"
  env            = var.env
  private_net_id = module.network.private_net_id
  db_password    = var.db_password
  db_name        = var.db_name
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}