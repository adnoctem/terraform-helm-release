module "release" {
  source = "../.."

  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart_version    = var.chart_version
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 600
  max_history      = 10
  values_object = {
    server = { service = { type = "ClusterIP" } }
  }
  service_accounts = {
    server = { name = "platform-argocd-server", annotations = { "example.com/team" = "platform" } }
  }
  service_account_paths = {
    server = { name = ["server", "serviceAccount", "name"], annotations = ["server", "serviceAccount", "annotations"] }
  }
  set      = [{ name = "server.replicas", value = "2", type = "auto" }]
  timeouts = { create = "15m", update = "15m", delete = "10m" }
}
