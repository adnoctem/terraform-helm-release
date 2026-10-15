terraform {
  required_version = ">= 1.11"
  required_providers {
    helm = { source = "hashicorp/helm", version = "~> 3.3" }
  }
}
resource "terraform_data" "settings" {
  input = { name = "computed", chart = "example", replicas = 2, values = "replicaCount: 2" }
}
module "subject" {
  source                = "../.."
  name                  = terraform_data.settings.output.name
  chart                 = terraform_data.settings.output.chart
  values                = [terraform_data.settings.output.values]
  values_object         = { nested = { count = terraform_data.settings.output.replicas } }
  service_accounts      = { controller = { name = terraform_data.settings.output.name } }
  service_account_paths = { controller = { name = ["serviceAccount", "name"] } }
}
output "name" {
  value       = module.subject.name
  description = "Computed release name."
}
