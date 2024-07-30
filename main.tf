terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2375"

registry_auth {
    address     = "registry.gitlab.com"
    config_file = pathexpand("~/.docker/config.json")
  }
}

resource "docker_image" "db_image" {
  name = "registry.gitlab.com/testing_group6034130/testing_poc_mckesson/db-postgres:v1.00"
}

resource "docker_image" "app_image" {
  name = "registry.gitlab.com/testing_group6034130/testing_poc_mckesson/login-app:v1.00"
}

resource "docker_network" "app_network" {
  name = "app_network"
}

resource "docker_container" "db_container" {
  name  = "postgres-container"
  image = docker_image.db_image.name
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 5432
    external = 5432
  }
}

resource "docker_container" "app_container" {
  name  = "nodejs-container"
  image = docker_image.app_image.name
  networks_advanced {
    name = docker_network.app_network.name
    aliases = ["postgres"]
  }
  ports {
    internal = 3000
    external = 3000
  }
}

output "app_url" {
  value = "Your application is now running on http://localhost:3000/"
}
