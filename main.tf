terraform {
	required_version = ">= 1.0"
	
	required_providers {
		docker = {
			source = "kreuzwerker/docker"
			version = "~>3.0"
		}
	}
}

provider "docker" {}

resource "docker_image" "nginx" {
	name = "nginx:latest"
	keep_locally = false
}

resource "docker_container" "nginx" {
	image = docker_image.nginx.image_id
	name = "tutorial_nginx"

	ports {
		internal = 80
		external = 8080
	}
}

output "container_id" {
	description = "ID of the Docker container"
	value = docker_container.nginx.id
}

output "container_name" {
	description = "Name of the Docker container"
	value = docker_container.nginx.name
}

output "nginx_url" {
	description = "URL to access nginx"
	value = "http://192.168.226.130:${docker_container.nginx.ports[0].external}"
}
