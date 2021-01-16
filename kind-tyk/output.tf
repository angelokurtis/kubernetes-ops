output "tyk_gateway_values" {
  value = yamldecode(file("values_community_edition.yaml"))
}