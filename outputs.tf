output "id" {
  value       = try(helm_release.current[0].id, null)
  description = "Helm release id, or null when disabled."
}

output "name" {
  value       = try(helm_release.current[0].name, null)
  description = "Helm release name, or null when disabled."
}

output "namespace" {
  value       = try(helm_release.current[0].namespace, null)
  description = "Helm release namespace, or null when disabled."
}

output "chart" {
  value       = try(helm_release.current[0].chart, null)
  description = "Helm release chart, or null when disabled."
}

output "chart_version" {
  value       = try(helm_release.current[0].version, null)
  description = "Helm release chart version, or null when disabled."
}

output "status" {
  value       = try(helm_release.current[0].status, null)
  description = "Helm release status, or null when disabled."
}

output "metadata" {
  value       = try(helm_release.current[0].metadata, null)
  description = "Helm release metadata, or null when disabled."
  sensitive   = true
}

output "manifest" {
  value       = try(helm_release.current[0].manifest, null)
  description = "Helm release manifest, or null when disabled."
  sensitive   = true
}

output "resources" {
  value       = try(helm_release.current[0].resources, null)
  description = "Helm release resources, or null when disabled."
  sensitive   = true
}
