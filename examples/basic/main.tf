module "release" {
  source = "../.."

  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts"
  chart_version    = "v1.21.2"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  values           = [yamlencode({ crds = { enabled = true } })]
}
