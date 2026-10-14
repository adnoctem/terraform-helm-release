terraform {
  required_version = ">= 1.11"
  required_providers {
    helm = { source = "hashicorp/helm", version = "~> 3.3" }
  }
}
resource "terraform_data" "settings" {
  input = { name = "computed", chart = "example", values = "replicaCount: 2" }
}
module "subject" {
  source = "../.."
  name   = terraform_data.settings.output.name
  chart  = terraform_data.settings.output.chart
  values = [terraform_data.settings.output.values]
}
output "name" {
  value       = module.subject.name
  description = "Computed release name."
}
