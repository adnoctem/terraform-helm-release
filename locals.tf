locals {
  # JSON strings keep heterogeneous fields (bool/string/maps) from being coerced.
  service_account_entries = flatten([
    for role, account in var.service_accounts : [
      for field, encoded in {
        name        = jsonencode(account.name)
        create      = jsonencode(account.create)
        annotations = jsonencode(account.annotations)
        labels      = jsonencode(account.labels)
        pod_labels  = jsonencode(account.pod_labels)
        } : {
        path    = lookup(lookup(var.service_account_paths, role, {}), field, [])
        encoded = encoded
      } if encoded != "null" && encoded != "{}"
    ]
  ])
  # JSON is valid YAML. Quoted keys build arbitrarily nested mappings without
  # treating dots/slashes as Helm path syntax or changing scalar value types.
  service_account_values = [for entry in local.service_account_entries :
    yamlencode(jsondecode("${join("", [for segment in entry.path : "{${jsonencode(segment)}:"])}${entry.encoded}${join("", [for segment in entry.path : "}"])}"))
    if length(entry.path) > 0
  ]
  values = concat(var.default_values, local.service_account_values, var.values_object == null ? [] : [yamlencode(var.values_object)], var.values)
}
