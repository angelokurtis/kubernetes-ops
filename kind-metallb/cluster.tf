resource "kind_cluster" "metallb" {
  name           = "metallb"
  wait_for_ready = true
}
