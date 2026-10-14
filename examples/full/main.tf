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
  values           = [yamlencode({ server = { service = { type = "ClusterIP" } } })]
  set              = [{ name = "server.replicas", value = "2", type = "auto" }]
  timeouts         = { create = "15m", update = "15m", delete = "10m" }
}
