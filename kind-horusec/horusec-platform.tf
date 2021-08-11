output "horusec_platform" {
  value = data.template_file.horusec_platform.rendered
}

data "template_file" "horusec_platform" {
  template = file("${path.module}/horusec-platform.yaml")
  vars = {
    NAMESPACE = kubernetes_namespace.horusec_system.metadata[0].name

    POSTGRESQL_HOST = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
    RABBITMQ_HOST = "rabbitmq.${kubernetes_namespace.queue.metadata[0].name}.svc.cluster.local"

    JWT_SECRET_NAME = kubernetes_secret.horusec_jwt.metadata[0].name
    SMTP_SECRET_NAME = kubernetes_secret.horusec_smtp.metadata[0].name
    RABBITMQ_SECRET_NAME = kubernetes_secret.horusec_broker.metadata[0].name
    ANALYTIC_DB_SECRET_NAME = kubernetes_secret.analytic_db.metadata[0].name
    PLATFORM_DB_SECRET_NAME = kubernetes_secret.platform_db.metadata[0].name
  }
}

resource "helm_release" "horusec_platform" {
  name = "horusec-platform"
  namespace = kubernetes_namespace.horusec_system.metadata[0].name
  chart = "${path.cwd}/horusec-platform.tar.gz"

  values = [ data.template_file.horusec_platform.rendered ]
}
