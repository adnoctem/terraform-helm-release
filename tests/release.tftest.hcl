mock_provider "helm" {
  mock_resource "helm_release" {
    defaults = { status = "deployed", id = "release-id" }
  }
}
# Explicit ephemeral input avoids a Terraform 1.11 test-runner default-value bug.
variables {
  set_wo = []
  name   = "example"
  chart  = "example-chart"
}
run "disabled" {
  command = plan
  variables { create = false }
  assert {
    condition     = output.name == null && output.metadata == null && length(helm_release.current) == 0
    error_message = "Disabled releases must have no resource or stale outputs."
  }
}
run "release_options_and_ordered_values" {
  command = apply
  variables {
    repository        = "https://charts.example.com"
    chart_version     = "1.2.3"
    namespace         = "platform"
    create_namespace  = true
    wait              = true
    timeout           = 900
    values            = ["replicaCount: 1", "replicaCount: 3"]
    set               = [{ name = "service.type", value = "ClusterIP", type = "string" }]
    set_list          = [{ name = "hosts", value = ["one.example.com", "two.example.com"] }]
    set_sensitive     = [{ name = "credential", value = "mock-only-value" }]
    postrender        = { binary_path = "/bin/cat", args = [] }
    timeouts          = { create = "20m", delete = "10m" }
    take_ownership    = true
    upgrade_install   = true
    disable_crd_hooks = true
  }
  assert {
    condition     = output.name == "example" && output.chart_version == "1.2.3" && output.status == "deployed" && output.namespace == "platform"
    error_message = "Identity and status outputs must describe this release."
  }
  assert {
    condition     = helm_release.current[0].values == tolist(["replicaCount: 1", "replicaCount: 3"]) && helm_release.current[0].set_list[0].value == tolist(["one.example.com", "two.example.com"])
    error_message = "Values and list overrides must retain caller order."
  }
  assert {
    condition     = helm_release.current[0].set_sensitive[0].value == "mock-only-value" && helm_release.current[0].timeouts.create == "20m" && helm_release.current[0].timeout == 900 && helm_release.current[0].postrender.binary_path == "/bin/cat"
    error_message = "Sensitive values, timeouts, and post-render settings must pass through."
  }
  assert {
    condition     = helm_release.current[0].take_ownership && helm_release.current[0].upgrade_install && helm_release.current[0].disable_crd_hooks
    error_message = "New provider controls must remain configurable."
  }
}
run "reject_empty_name" {
  command = plan
  variables { name = " " }
  expect_failures = [var.name]
}
run "computed_inputs" {
  command = plan
  module { source = "./tests/setup" }
}

run "write_only_values" {
  command = apply
  variables {
    set_wo          = [{ name = "password", value = "mock-ephemeral-value" }]
    set_wo_revision = 1
  }
  assert {
    condition     = helm_release.current[0].set_wo == null && helm_release.current[0].set_wo_revision == 1
    error_message = "Write-only values must not be returned as resource state; retain only the revision."
  }
}
