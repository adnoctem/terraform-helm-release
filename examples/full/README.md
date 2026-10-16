# Full Helm release example

This configuration shows every root input and nested field, using a real chart to demonstrate
layered values and explicit service-account paths. It is a configuration reference, not an
application deployment guide. Supply `chart_version`, `sensitive_value`, and `write_only_value`.
The paths match the [chart value reference](https://github.com/argoproj/argo-helm/blob/argo-cd-10.10.3/charts/argo-cd/values.yaml).

The value layers demonstrate `default_values`, generated account settings, `values_object`, YAML
`values`, and each `set` variant. Sensitive values remain in Terraform state. Ephemeral write-only
values do not, but Helm release data and chart-created Secrets may contain them; increment
`write_only_revision` when they change. Never commit actual credentials.

Repository credentials and TLS files are optional and default to null for the public chart source.
Use matching files and credentials only with a repository that needs them. `verify = false` leaves
provenance verification off; enable it with a matching keyring and a chart with a provenance signature.
The `cat -` post-renderer demonstrates both fields without changing the manifests and requires `cat`
on PATH. Replace it with your own executable and arguments, or set `postrender = null` to omit it.

Mutually exclusive or disruptive alternatives are shown in their ordinary settings: `reset_values`
is true and `reuse_values` false; replacement, forced updates, adoption, and upgrade-install are off.
`create = false` plans removal of an existing release. Do not use it as a dry run.

## Running the example

Set the example inputs, then run `terraform init`, `terraform plan`, and `terraform apply`.
Cluster connection settings are in `versions.tf`. See the [module README](../../README.md) for the
input contract and lifecycle notes.
