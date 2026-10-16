module "release" {
  source = "../.."

  create                     = true
  name                       = "argocd"
  chart                      = "argo-cd"
  repository                 = "https://argoproj.github.io/argo-helm"
  chart_version              = var.chart_version
  namespace                  = "argocd"
  default_values             = [yamlencode({ global = { logging = { level = "info" } } })]
  set_wo                     = [{ name = "configs.secret.extra.example-write-only", type = "string", value = var.write_only_value }]
  atomic                     = false
  cleanup_on_fail            = true
  create_namespace           = true
  dependency_update          = false
  description                = "Managed platform release"
  devel                      = false
  disable_crd_hooks          = false
  disable_openapi_validation = false
  disable_webhooks           = false
  force_update               = false
  keyring                    = var.keyring
  lint                       = false
  max_history                = 10
  pass_credentials           = false
  postrender = {
    binary_path = "cat"
    args        = ["-"]
  }
  recreate_pods         = false
  render_subchart_notes = true
  replace               = false
  repository_ca_file    = var.repository_auth.ca_file
  repository_cert_file  = var.repository_auth.cert_file
  repository_key_file   = var.repository_auth.key_file
  repository_password   = var.repository_auth.password
  repository_username   = var.repository_auth.username
  reset_values          = true
  reuse_values          = false
  set                   = [{ name = "server.replicas", type = "auto", value = "2" }]
  set_list              = [{ name = "server.extraArgs", value = ["--loglevel", "info"] }]
  set_sensitive         = [{ name = "configs.secret.extra.example-sensitive", type = "string", value = var.sensitive_value }]
  set_wo_revision       = var.write_only_revision
  skip_crds             = false
  take_ownership        = false
  timeout               = 600
  timeouts = {
    create = "15m"
    update = "15m"
    read   = "5m"
    delete = "10m"
  }
  upgrade_install = false
  values          = [yamlencode({ global = { logging = { format = "json" } } })]
  values_object   = { server = { service = { type = "ClusterIP" } } }
  service_accounts = {
    server = {
      name        = "platform-server"
      create      = true
      annotations = { "example.com/team" = "platform" }
      labels      = { environment = "example" }
      pod_labels  = { "example.com/identity" = "platform" }
    }
  }
  service_account_paths = {
    server = {
      name        = ["server", "serviceAccount", "name"]
      create      = ["server", "serviceAccount", "create"]
      annotations = ["server", "serviceAccount", "annotations"]
      labels      = ["server", "serviceAccount", "labels"]
      pod_labels  = ["server", "podLabels"]
    }
  }
  verify        = false
  wait          = true
  wait_for_jobs = true
}
