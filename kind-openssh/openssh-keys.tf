resource "tls_private_key" "openssh" {
  algorithm = "RSA"
  rsa_bits = "4096"
}

resource "local_file" "private_key" {
  filename = "${path.cwd}/ssh/id_rsa"
  content = tls_private_key.openssh.private_key_pem
}

resource "local_file" "public_key" {
  filename = "${path.cwd}/ssh/id_rsa.pub"
  content = tls_private_key.openssh.public_key_openssh
}
