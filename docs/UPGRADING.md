# Upgrade guide

## v1 to v2

This is a breaking API change from the old `terraform-helm-releases` Git module.
The repository is now singular and each invocation owns one release. The old v1 tag remains available for reference.
Use Terraform >= 1.11 or OpenTofu >= 1.11 and Helm provider ~> 3.3.

Move provider authentication into your root configuration. Helm 3 uses
`kubernetes = { ... }`, not a nested `kubernetes` block. The wrapper needs no Kubernetes provider.
Replace the `releases` map with individual module calls (or caller `for_each`) and use
`chart_version` for the previous per-release `version`. Replace the custom `depends` input with
normal module `depends_on` or resource references. Nested `set*` settings use lists of objects.
The previous malformed output collection is replaced by individual release outputs.

Back up state and inspect the existing addresses with `terraform state list`.
For a release previously at `module.releases.helm_release.current["web"]`, a caller-side move can be:

```hcl
moved {
  from = module.releases.helm_release.current["web"]
  to   = module.web.helm_release.current[0]
}
```

Use your actual module paths and keys. Moving to a module `for_each` also introduces its caller key.
Renaming a source URL alone does not move resources. There is no universal internal moved block
for arbitrary old release keys. Keep the same release name and namespace to retain Helm identity.

### Embedded provider migration

Do not remove the old embedded provider configuration while state still depends on it.
Use a transitional copy of v1 that retains its resource addresses and old embedded Helm provider.
Add a distinct `helm.migration` configuration alias to its required providers, pass the caller's Helm
provider under that alias, and set the release resource's provider to `helm.migration`. Apply a reviewed
plan to record the caller-provider association before removing the old provider block. Then switch to
the unaliased caller provider, upgrade the module API, and move resource addresses. Keep the provider
major version unchanged during this rebinding step.
A provider-major upgrade is a separate review step: follow the upstream migration guide and inspect
the plan for resource updates. Do not run destroy merely to resolve a missing provider configuration.

These are migration instructions, not a claim that a production state migration was performed here.
Rehearse the complete transition against a disposable cluster before using it on live releases.

## Validation and releases

Native mocked tests cover creation gating, option propagation, ordered values, and computed inputs.
They do not exercise Helm install/upgrade hooks, chart rendering, CRDs, or live provider authentication.
Validate these against your selected charts and cluster before release. Review a second no-change plan.

Publish the v2 release module before foundation's pinned registry dependency. Public registry
publication is a separate action from committing code, pushing a tag, or changing README links.

Regenerate README with `terraform-docs -c .github/linters/.terraform-docs.yml .` and coverage with
`formr schema . -o docs/SCHEMA.md`. Check drift with `formr check . --report docs/SCHEMA.md`.
Provider configurations are caller-owned. Computed IDs/results and write-only inputs are not
ordinary configurable outputs. Document any analysis limitations rather than hand-editing SCHEMA.md.

The current Formr report incorrectly marks the resource's `version` field as omitted despite the
explicit `version = var.chart_version` mapping. The native option test verifies this mapping.
This is an analysis limitation; retain the generated report unchanged until Formr is corrected.

## Release conveniences

`name` and `chart` can now be omitted only when `create=false`. Existing enabled calls and raw YAML
inputs keep their behavior. Collection nulls normalize to empty values. New checks reject invalid
release names, numeric options, duplicate exact `set*` paths, and unsupported override types.
Write-only values now require a positive `set_wo_revision`; otherwise the provider may not consume them.

`default_values`, `values_object`, and mapped `service_accounts` are additive inputs. Review the README
precedence contract before moving settings between these layers. Account annotations and labels are
ordinary chart values, not a secret transport or proof that cloud trust has been configured.
