resource "kubectl_manifest" "kustomization_football_bets" {
  yaml_body = <<-YAML
    apiVersion: kustomize.toolkit.fluxcd.io/v1
    kind: Kustomization
    metadata:
      name: football-bets
      namespace: ${kubernetes_namespace.demo.metadata[0].name}
    spec:
      interval: 10s
      prune: true
      targetNamespace: ${kubernetes_namespace.demo.metadata[0].name}
      path: "./manifests/overlays/agent-instrumentation/"
      sourceRef:
        kind: GitRepository
        name: football-bets
        namespace: ${kubernetes_namespace.flux.metadata[0].name}
      healthChecks:
        - kind: Deployment
          name: bets
          namespace: ${kubernetes_namespace.demo.metadata[0].name}
        - kind: Deployment
          name: championships
          namespace: ${kubernetes_namespace.demo.metadata[0].name}
        - kind: Deployment
          name: matches
          namespace: ${kubernetes_namespace.demo.metadata[0].name}
        - kind: Deployment
          name: teams
          namespace: ${kubernetes_namespace.demo.metadata[0].name}
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "git_repository_football_bets" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: football-bets
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 10s
      url: https://github.com/angelokurtis/football-bets
      ref:
        branch: multiverse/java-spring-prom
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_ingress_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "demo.${local.cluster_host}"
      http {
        path {
          path = "/bets"
          backend {
            service {
              name = "bets"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/championships"
          backend {
            service {
              name = "championships"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/matches"
          backend {
            service {
              name = "matches"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/teams"
          backend {
            service {
              name = "teams"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "demo" {
  metadata { name = "demo" }
}
