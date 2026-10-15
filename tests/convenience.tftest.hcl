mock_provider "helm" {}
variables {
  name   = "example"
  chart  = "example"
  set_wo = []
}
run "disabled_without_required_inputs" {
  command = plan
  variables {
    create = false
    name   = null
    chart  = null
  }
  assert {
    condition     = output.name == null && length(helm_release.current) == 0
    error_message = "Disabled releases must not require placeholder identities."
  }
}
run "layered_values_and_literal_keys" {
  command = apply
  variables {
    default_values = ["serviceAccount:\n  annotations:\n    default: retained\n"]
    values_object  = { replicas = 2, enabled = true, nested = { list = [1, 2], text = "false" } }
    values         = ["replicas: 3", "replicas: 4"]
    service_accounts = {
      controller = { name = "controller", create = false, annotations = { "example.com/identity" = "test-identity" }, pod_labels = { "azure.workload.identity/use" = "true" } }
    }
    service_account_paths = {
      controller = { name = ["serviceAccount", "name"], create = ["serviceAccount", "create"], annotations = ["serviceAccount", "annotations"], pod_labels = ["workload.with.dots", "podLabels"] }
    }
  }
  assert {
    condition     = yamldecode(helm_release.current[0].values[0]).serviceAccount.annotations.default == "retained" && slice(helm_release.current[0].values, 6, 8) == tolist(["replicas: 3", "replicas: 4"])
    error_message = "Defaults must come first and caller YAML must remain last and ordered."
  }
  assert {
    condition     = yamldecode(helm_release.current[0].values[5]).replicas == 2 && yamldecode(helm_release.current[0].values[5]).enabled == true && yamldecode(helm_release.current[0].values[5]).nested.text == "false"
    error_message = "Encoding must preserve nested number, boolean, and string values."
  }
  assert {
    condition     = yamldecode(helm_release.current[0].values[1]).serviceAccount.annotations["example.com/identity"] == "test-identity" && yamldecode(helm_release.current[0].values[2]).serviceAccount.create == false && yamldecode(helm_release.current[0].values[4])["workload.with.dots"].podLabels["azure.workload.identity/use"] == "true"
    error_message = "Mapped account settings must preserve false and literal keys without Helm path escaping."
  }
}
run "explicit_null_collections" {
  command = plan
  variables {
    values                = null
    default_values        = null
    set                   = null
    set_sensitive         = null
    set_list              = null
    service_accounts      = null
    service_account_paths = null
  }
  assert {
    condition     = length(helm_release.current[0].values) == 0
    error_message = "Explicit null collections must normalize to empty collections."
  }
}
run "literal_set_types" {
  command = plan
  variables { set = [{ name = "text", value = "a,b", type = "literal" }] }
}
run "reject_missing_name" {
  command = plan
  variables {
    name = null
  }
  expect_failures = [var.name]
}
run "reject_missing_chart" {
  command = plan
  variables {
    chart = null
  }
  expect_failures = [var.chart]
}
run "reject_invalid_name" {
  command = plan
  variables {
    name = "Not_A_Name"
  }
  expect_failures = [var.name]
}
run "reject_negative_timeout" {
  command = plan
  variables {
    timeout = -1
  }
  expect_failures = [var.timeout]
}
run "reject_fractional_timeout" {
  command = plan
  variables {
    timeout = 1.5
  }
  expect_failures = [var.timeout]
}
run "reject_negative_history" {
  command = plan
  variables {
    max_history = -1
  }
  expect_failures = [var.max_history]
}
run "reject_invalid_revision" {
  command = plan
  variables {
    set_wo_revision = 0
  }
  expect_failures = [var.set_wo_revision]
}
run "reject_scalar_values" {
  command = plan
  variables {
    values_object = "not-an-object"
  }
  expect_failures = [var.values_object]
}
run "reject_list_values" {
  command = plan
  variables {
    values_object = [1, 2]
  }
  expect_failures = [var.values_object]
}
run "reject_invalid_set_type" {
  command = plan
  variables {
    set = [{ name = "test", type = "invalid" }]
  }
  expect_failures = [var.set]
}
run "reject_empty_path" {
  command = plan
  variables {
    set_list = [{ name = "", value = [] }]
  }
  expect_failures = [var.set_list]
}
run "reject_duplicate_paths" {
  command = plan
  variables {
    set           = [{ name = "test", value = "first" }]
    set_sensitive = [{ name = "test", value = "second" }]
  }
  expect_failures = [var.set_sensitive]
}
run "reject_write_only_duplicate" {
  command = plan
  variables {
    set             = [{ name = "test", value = "first" }]
    set_wo          = [{ name = "test", value = "second" }]
    set_wo_revision = 1
  }
  expect_failures = [var.set_wo]
}
run "reject_missing_revision" {
  command = plan
  variables {
    set_wo = [{ name = "test", value = "mock-value" }]
  }
  expect_failures = [var.set_wo]
}
run "reject_unsupported_account_field" {
  command = plan
  variables {
    service_accounts = { controller = { name = "missing-mapping" } }
  }
  expect_failures = [var.service_accounts]
}
run "reject_duplicate_account_paths" {
  command = plan
  variables {
    service_accounts      = { one = { name = "one" }, two = { name = "two" } }
    service_account_paths = { one = { name = ["name"] }, two = { name = ["name"] } }
  }
  expect_failures = [var.service_accounts]
}
run "reject_invalid_account_path" {
  command = plan
  variables {
    service_account_paths = { one = { name = [""] } }
  }
  expect_failures = [var.service_account_paths]
}

run "dotted_release_name" {
  command = plan
  variables { name = "valid.name" }
}
run "reject_null_account" {
  command = plan
  variables { service_accounts = { controller = null } }
  expect_failures = [var.service_accounts]
}
run "reject_null_account_path" {
  command = plan
  variables { service_account_paths = { controller = { name = null } } }
  expect_failures = [var.service_account_paths]
}
