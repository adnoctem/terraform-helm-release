# Helm Release Terraform module

Manage one Helm release with layered values, chart-side service-account mappings, and write-only
overrides. Releases work with caller-configured Kubernetes clusters.

## Usage

Copy this configuration into `main.tf` and supply the chart coordinates for your release.

```hcl
variable "chart" {
  description = "Chart name, repository URL, and exact chart version to install."
  type = object({
    name       = string
    repository = string
    version    = string
  })
}

module "release" {
  source  = "registry.terraform.io/adnoctem/release/helm"
  version = "~> 2.0"

  name             = "platform-service"
  chart            = var.chart.name
  repository       = var.chart.repository
  chart_version    = var.chart.version
  namespace        = "platform-system"
  create_namespace = true
  atomic           = true
  timeout          = 600
}
```

## Examples

- [Basic](examples/basic): a single release with caller-supplied chart version.
- [Full](examples/full): every input and nested field, layered values, service-account mappings,
  repository settings, and write-only overrides.

## Configuration

Provider authentication, registry credentials, and aliases belong to the caller. There are no
embedded provider configurations or cluster-token inputs. Use a module `for_each` for independent
releases, or separate module calls with `depends_on` when releases have installation dependencies.
`create = false` removes an existing managed release and returns null outputs. A disabled call may
omit `name` and `chart`; enabled calls require a valid Helm release name and a nonempty chart.

All configurable fields in the Helm 3.3 resource schema are exposed. `chart_version` maps to the
provider's `version` because `version` is reserved in module calls. Optional null settings use provider
defaults. `timeout` controls Helm operations in seconds; `timeouts` controls Terraform provider operations.
See [basic](examples/basic) and [full](examples/full) for concrete configurations.

Values are composed in a documented order, from lowest to highest priority:

1. The chart's own defaults.
2. `default_values`: optional YAML defaults supplied by a catalog or another caller.
3. Generated `service_accounts` settings, using explicit chart paths.
4. `values_object`: a native HCL object/map, encoded without flattening nested types.
5. `values`: caller YAML documents, in their supplied order.
6. Helm `set`, `set_list`, `set_sensitive`, and write-only overrides.

Helm performs nested merging. The module does not use Terraform's shallow `merge()` on chart values.
Use `file` or `templatefile` for YAML; paths are resolved in the calling configuration. `values_object`
accepts arbitrary nested types but requires an object/map at the top level. Exact override paths must
be unique across the `set*` collections; override the same key in a later YAML layer when layering is
intentional. Parent/child path conflicts and equivalent Helm-escaped spellings are not canonicalized.

Explicit null values for ordinary collection inputs become empty collections. Null scalar options
retain provider defaults. Invalid timeouts, history counts, release names, override types, and write-only
revisions fail with module diagnostics. `literal` is supported for `set`/`set_sensitive`; write-only
entries accept `auto` or `string`, matching the provider.

Sensitive marking hides values in normal CLI output but does not remove them from Terraform state.
Metadata, rendered manifests, and resource details are exported as sensitive because charts may
include secrets there.

`set_wo` is sensitive and ephemeral and passes directly to the provider's write-only argument.
Increment `set_wo_revision` when it changes. Its values are not retained as Terraform input/state
attributes, but Helm stores release information in Kubernetes and charts may create Secrets.
Do not use ordinary values or sensitive overrides expecting the same write-only behavior.

## Service accounts and workload identity

The wrapper translates logical account roles into chart values. For a chart using a conventional
service-account object, a caller can provide:

```hcl
service_accounts = {
  controller = {
    name        = "controller"
    create      = false
    annotations = { "example.com/identity" = "existing-identity" }
  }
}
service_account_paths = {
  controller = {
    name        = ["serviceAccount", "name"]
    create      = ["serviceAccount", "create"]
    annotations = ["serviceAccount", "annotations"]
  }
}
```

Paths are lists of literal YAML keys. Dots, slashes, and commas in annotation keys require no Helm
escaping. Supported settings are `name`, `create`, `annotations`, `labels`, and `pod_labels`; every
populated setting needs a mapping. Missing mappings fail rather than silently dropping a setting.
Multiple roles support charts with multiple accounts. Maps merge through Helm, and later caller values
may override generated settings. Account mappings must not target the same path twice.

`create=false` asks the chart to use an existing account where the chart supports that behavior; its
annotations/labels must be managed by that account's owner. It does not mutate an existing ServiceAccount
outside Helm. This module creates no separate Kubernetes or cloud resources. Cloud identity adapters
can supply annotations, pod labels, and account names, while IAM/federation/associations remain outside
this module. Omit the role or conditionally pass `{}` to disable this convenience.

## Compatibility and maintenance

Requires Terraform >= 1.11 or OpenTofu >= 1.11, and Helm provider ~> 3.3.
The CI matrix covers Terraform 1.11.4/1.16.6 and OpenTofu 1.11.14/1.13.1.
Native tests mock Helm and create no cluster resources. They do not establish live chart compatibility.

Run `terraform init -backend=false`, `terraform validate`, and `terraform test`.
Read the [upgrade guide](docs/UPGRADING.md) for the breaking v1 migration.
The [schema report](docs/SCHEMA.md) records provider coverage. Regenerate with
`formr schema . -o docs/SCHEMA.md` and verify with `formr check . --report docs/SCHEMA.md`.
Formr's default policy checks inventory and unresolved analysis, not runtime correctness.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| helm | ~> 3.3 |

## Providers

| Name | Version |
| ---- | ------- |
| helm | ~> 3.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.current](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| atomic | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `null` | no |
| chart | Chart name, URL, or local path. Required only when create is true. | `string` | `null` | no |
| chart\_version | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `null` | no |
| cleanup\_on\_fail | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `null` | no |
| create | Whether to manage this Helm release. False removes an existing managed release. | `bool` | `true` | no |
| create\_namespace | Create the namespace if it does not exist | `bool` | `null` | no |
| default\_values | Low-priority YAML defaults for composition by catalogs. Service-account settings, values\_object, values, and set overrides take precedence, in that order. | `list(string)` | `[]` | no |
| dependency\_update | Run helm dependency update before installing the chart | `bool` | `null` | no |
| description | Add a custom description | `string` | `null` | no |
| devel | Use chart development versions, too. Equivalent to version '>0.0.0-0'. If 'version' is set, this is ignored | `bool` | `null` | no |
| disable\_crd\_hooks | Prevent CRD hooks from running, but run other hooks. See helm install --no-crd-hook | `bool` | `null` | no |
| disable\_openapi\_validation | If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema | `bool` | `null` | no |
| disable\_webhooks | Prevent hooks from running | `bool` | `null` | no |
| force\_update | Force resource update through delete/recreate if needed. | `bool` | `null` | no |
| keyring | Location of public keys used for verification, Used only if 'verify is true' | `string` | `null` | no |
| lint | Run helm lint when planning | `bool` | `null` | no |
| max\_history | Limit the maximum number of revisions saved per release. Use 0 for no limit | `number` | `null` | no |
| name | Release name, at most 53 characters. Required only when create is true. | `string` | `null` | no |
| namespace | Namespace to install the release into | `string` | `null` | no |
| pass\_credentials | Pass credentials to all domains | `bool` | `null` | no |
| postrender | Postrender command config | ```object({ args = optional(list(string)) binary_path = string })``` | `null` | no |
| recreate\_pods | Perform pods restart during upgrade/rollback | `bool` | `null` | no |
| render\_subchart\_notes | If set, render subchart notes along with the parent | `bool` | `null` | no |
| replace | Re-use the given name, even if that name is already used. This is unsafe in production | `bool` | `null` | no |
| repository | Repository where to locate the requested chart. If it is a URL, the chart is installed without installing the repository | `string` | `null` | no |
| repository\_ca\_file | The Repositories CA file | `string` | `null` | no |
| repository\_cert\_file | The repositories cert file | `string` | `null` | no |
| repository\_key\_file | The repositories cert key file | `string` | `null` | no |
| repository\_password | Password for HTTP basic authentication | `string` | `null` | no |
| repository\_username | Username for HTTP basic authentication | `string` | `null` | no |
| reset\_values | When upgrading, reset the values to the ones built into the chart | `bool` | `null` | no |
| reuse\_values | When upgrading, reuse the last release's values and merge in any overrides. If 'reset\_values' is specified, this is ignored | `bool` | `null` | no |
| service\_account\_paths | Role -> field -> chart key segments. Supported fields: name, create, annotations, labels, pod\_labels. Segments are literal keys, so dots/slashes need no Helm escaping. Omit unsupported fields. | `map(map(list(string)))` | `{}` | no |
| service\_accounts | Chart-side service-account and workload identity settings keyed by logical role. Each populated field needs an explicit service\_account\_paths mapping. Does not create cloud identities or separate Kubernetes resources. | ```map(object({ name = optional(string) create = optional(bool) annotations = optional(map(string), {}) labels = optional(map(string), {}) pod_labels = optional(map(string), {}) }))``` | `{}` | no |
| set | Custom values to be merged with the values | ```list(object({ name = string type = optional(string) value = optional(string) }))``` | `[]` | no |
| set\_list | List-valued Helm overrides | ```list(object({ name = string value = list(string) }))``` | `[]` | no |
| set\_sensitive | Custom sensitive values to be merged with the values | ```list(object({ name = string type = optional(string) value = string }))``` | `[]` | no |
| set\_wo | Write-only Helm overrides. Increment set\_wo\_revision on changes. Ephemeral inputs are not retained in Terraform state; Helm still persists release data in Kubernetes. | ```list(object({ name = string type = optional(string) value = string }))``` | `null` | no |
| set\_wo\_revision | The current revision of the write-only "set\_wo" attribute. Incrementing this integer value will cause Terraform to update the write-only value. | `number` | `null` | no |
| skip\_crds | If set, no CRDs will be installed. By default, CRDs are installed if not already present | `bool` | `null` | no |
| take\_ownership | If set, Helm will take ownership of resources not already annotated by this release. Useful for migrations or recovery. | `bool` | `null` | no |
| timeout | Time in seconds to wait for any individual kubernetes operation | `number` | `null` | no |
| timeouts | Terraform provider operation timeouts, separate from the Helm timeout in seconds. | ```object({ create = optional(string) delete = optional(string) read = optional(string) update = optional(string) })``` | `null` | no |
| upgrade\_install | If true, the provider will install the release at the specified version even if a release not controlled by the provider is present. This is equivalent to running 'helm upgrade --install'. WARNING: this may not be suitable for production use -- see the 'Upgrade Mode' note in the provider documentation. Defaults to `false`. | `bool` | `null` | no |
| values | List of values in raw YAML format to pass to helm | `list(string)` | `[]` | no |
| values\_object | A native HCL object/map encoded as YAML before values. Nested types are preserved; Helm performs the merge. Ordinary values remain in state. | `any` | `null` | no |
| verify | Verify the package before installing it. | `bool` | `null` | no |
| wait | Will wait until all resources are in a ready state before marking the release as successful. | `bool` | `null` | no |
| wait\_for\_jobs | If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. | `bool` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| chart | Helm release chart, or null when disabled. |
| chart\_version | Helm release chart version, or null when disabled. |
| id | Helm release id, or null when disabled. |
| manifest | Helm release manifest, or null when disabled. |
| metadata | Helm release metadata, or null when disabled. |
| name | Helm release name, or null when disabled. |
| namespace | Helm release namespace, or null when disabled. |
| resources | Helm release resources, or null when disabled. |
| status | Helm release status, or null when disabled. |
<!-- END_TF_DOCS -->

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for local checks and contribution guidelines, and
[UPGRADING.md](docs/UPGRADING.md) for compatibility and acceptance checks.

## Authors

Maintained by [Ad Noctem Collective](https://github.com/adnoctem).
See [AUTHORS](.github/AUTHORS) and [CODEOWNERS](.github/CODEOWNERS).

## License

MIT. See [LICENSE](LICENSE).
