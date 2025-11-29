resource "talos_cluster_kubeconfig" "_" {
  depends_on = [
    talos_machine_bootstrap.control_plane
  ]
  client_configuration = talos_machine_secrets._.client_configuration
  node                 = values(local.control_planes)[0].ip
}

resource "local_file" "kubeconfig" {
  content              = talos_cluster_kubeconfig._.kubeconfig_raw
  filename             = "${path.module}/kubeconfig"
  file_permission      = "0600"
  directory_permission = "0700"
}
