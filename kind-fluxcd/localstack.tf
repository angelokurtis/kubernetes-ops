data "docker_network" "kind" {
  name = "kind"
}

data "docker_registry_image" "localstack" {
  name = "localstack/localstack:0.14.3"
}

resource "docker_image" "localstack" {
  name          = data.docker_registry_image.localstack.name
  pull_triggers = [data.docker_registry_image.localstack.sha256_digest]
}

resource "docker_container" "localstack" {
  name  = "localstack"
  image = docker_image.localstack.latest

  ports {
    external = 4566
    internal = 4566
  }

  env = ["SERVICES=s3"]

  networks_advanced {
    name = data.docker_network.kind.name
  }
}

output "localstack" {
  value = docker_container.localstack.ip_address
}

resource "local_file" "bitnami" {
  filename = "bitnami.json"
  content  = jsonencode(aws_s3_bucket.bitnami)
}

resource "aws_s3_bucket" "bitnami" {
  bucket     = "bitnami"
  depends_on = [docker_container.localstack]
}

resource "aws_s3_object" "bitnami" {
  for_each = fileset("bitnami/", "**")
  bucket   = aws_s3_bucket.bitnami.id
  key      = each.value
  source   = "bitnami/${each.value}"
  etag     = filemd5("bitnami/${each.value}")
}
