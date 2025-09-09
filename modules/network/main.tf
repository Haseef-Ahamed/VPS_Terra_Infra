resource "docker_network" "public" {
  name   = "${var.env}-public-net"
  driver = "bridge"
}

resource "docker_network" "private" {
  name     = "${var.env}-private-net"
  driver   = "bridge"
  internal = true
}