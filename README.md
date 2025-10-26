# Day 4: Infrastructure as Code with Terraform

This project demonstrates the core principles of Infrastructure as Code (IaC) by using Terraform to provision and manage a Docker container.

Instead of manually running `docker` commands, the entire desired state of the infrastructure is defined declaratively in the `main.tf` file. Terraform then automates the process of creating, modifying, and destroying infrastructure to match this desired state.

## Project Structure

*   `main.tf`: The Terraform configuration file that defines the Docker provider, the NGINX image, the NGINX container, and several useful outputs.
*   `apply.log`: A log file capturing the output of `terraform apply`, showing the successful creation of the resources.
*   `destroy.log`: A log file capturing the output of `terraform destroy`, showing the successful cleanup of the resources.
*   `.gitignore`: Prevents Terraform state files (`.tfstate`) and local provider plugins (`.terraform`) from being committed to the repository.

## The Professional Terraform Workflow

For this project, a safe, two-step workflow was used to ensure predictability and prevent accidental changes. This is a best practice for professional and automated environments.

1.  **`terraform init`**: Initialized the project and downloaded the necessary Docker provider plugins based on the `required_providers` block in `main.tf`.

2.  **`terraform plan -out=tfplan`**: This command creates an execution plan and saves it to a file named `tfplan`. This captures the exact set of actions Terraform will take, allowing for review before any changes are made.

3.  **`terraform apply "tfplan"`**: This command executes the pre-approved plan from the `tfplan` file. It applies the changes without asking for confirmation, as the plan itself is the approval.

4.  **`terraform destroy`**: This command removes all infrastructure managed by this configuration, leaving the system in a clean state.

## Configuration (`main.tf`)

The `main.tf` file defines the desired state of our infrastructure.

```hcl
# 1. Terraform Block: Defines required versions for Terraform and providers.
terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# 2. Provider Block: Configures the Docker provider to connect to the local Docker daemon.
provider "docker" {}

# 3. Resource Block: Pulls the latest NGINX image from Docker Hub.
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# 4. Resource Block: Creates and runs a container from the NGINX image.
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial_nginx"

  ports {
    internal = 80
    external = 8080
  }
}

# 5. Output Blocks: Exposes useful information about the created resources.
# These values are displayed after a successful 'terraform apply'.
output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "Name of the Docker container"
  value       = docker_container.nginx.name
}

output "nginx_url" {
  description = "URL to access nginx"
  value       = "http://192.168.226.130:${docker_container.nginx.ports[0].external}"
}
```

---

## Execution Proof

The following is a log of the terminal session, demonstrating the complete Terraform workflow: initializing, planning, applying, verifying the NGINX service, and finally, destroying the infrastructure.

```bash
devops@adi:~/elevatelabs/task-04/terraform-docker$ terraform plan -out=tfplan

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.nginx will be created
  + resource "docker_container" "nginx" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + must_run                                    = true
      + name                                        = "tutorial_nginx"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = false
      + name         = "nginx:latest"
      + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + container_id   = (known after apply)
  + container_name = "tutorial_nginx"
  + nginx_url      = "http://192.168.226.130:8080"

─────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"

devops@adi:~/elevatelabs/task-04/terraform-docker$ terraform apply "tfplan"
docker_image.nginx: Creating...
docker_image.nginx: Still creating... [00m10s elapsed]
docker_image.nginx: Creation complete after 19s [id=sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aabnginx:latest]
docker_container.nginx: Creating...
docker_container.nginx: Creation complete after 1s [id=ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

container_id = "ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4"
container_name = "tutorial_nginx"
nginx_url = "http://192.168.226.130:8080"

devops@adi:~/elevatelabs/task-04/terraform-docker$ curl http://192.168.226.130:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

devops@adi:~/elevatelabs/task-04/terraform-docker$ terraform destroy -auto-approve
docker_image.nginx: Refreshing state... [id=sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aabnginx:latest]
docker_container.nginx: Refreshing state... [id=ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # docker_container.nginx will be destroyed
  - resource "docker_container" "nginx" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "ecb2dada3641" -> null
      - id                                          = "ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4" -> null
      - image                                       = "sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aab" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "tutorial_nginx" -> null
      - network_data                                = [
          - {
              - gateway                   = "172.17.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.17.0.2"
              - ip_prefix_length          = 16
              - mac_address               = "6e:17:94:82:08:cd"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (7 unchanged attributes hidden)

      - ports {
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }

  # docker_image.nginx will be destroyed
  - resource "docker_image" "nginx" {
      - id           = "sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aabnginx:latest" -> null
      - image_id     = "sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aab" -> null
      - keep_locally = false -> null
      - name         = "nginx:latest" -> null
      - repo_digest  = "nginx@sha256:029d4461bd98f124e531380505ceea2072418fdf28752aa73b7b273ba3048903" -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - container_id   = "ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4" -> null
  - container_name = "tutorial_nginx" -> null
  - nginx_url      = "http://192.168.226.130:8080" -> null
docker_container.nginx: Destroying... [id=ecb2dada3641acba5a0e44039b820304c7f8c948c886c339072ad7de6e4d58e4]
docker_container.nginx: Destruction complete after 0s
docker_image.nginx: Destroying... [id=sha256:657fdcd1c3659cf57cfaa13f40842e0a26b49ec9654d48fdefee9fc8259b4aabnginx:latest]
docker_image.nginx: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```
