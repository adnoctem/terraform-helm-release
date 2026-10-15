<p align="center">
    <!-- terraform-helm-release -->
    <img src="https://cdn.simpleicons.org/terraform/844FBA" alt="Terraform Logo" align="center" width="128">
    <h1 align="center">Ad Noctem Collective</h1>
    <h2 align="center"><code>release</code></h2>
</p>

[![License](https://img.shields.io/github/license/adnoctem/terraform-helm-release?label=License)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-_>=_1.11-brightgreen?logo=terraform&logoColor=623CE4)][terraform]
[![OpenTofu](https://img.shields.io/badge/OpenTofu-_>=_1.11-brightgreen?logo=opentofu)][opentofu]
[![CI Status](https://github.com/adnoctem/terraform-helm-release/actions/workflows/testing.yaml/badge.svg)](https://github.com/adnoctem/terraform-helm-release/actions/workflows/testing.yaml)
[![GitHub Release](https://img.shields.io/github/v/release/adnoctem/terraform-helm-release?label=Release)][github_releases]
[![GitHub Activity](https://img.shields.io/github/commit-activity/m/adnoctem/terraform-helm-release?label=Commits)][github_commits]
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovate&logoColor=1A1F6C)][renovate]
[![Pre-Commit](https://img.shields.io/badge/PreCommit-enabled-brightgreen?logo=precommit&logoColor=FAB040)][pre-commit]

A [Terraform module][module] to manage one Helm release on a caller-configured Kubernetes cluster.

## ✨ TL;DR

```hcl
module "release" {
  source = "git::https://github.com/adnoctem/terraform-helm-release.git?ref=v2.0.0"

  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart_version    = "10.10.3"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
}
```

The example targets the upcoming v2 release; it does not claim the tag is already published.
After registry publication, use `source = "adnoctem/release/helm"` with `version = "~> 2.0"`.
Repository examples use local sources and work before publication.

## Configuration

Configure the Helm provider in the calling root, for example:

```hcl
provider "helm" {
  kubernetes = { config_path = pathexpand("~/.kube/config") }
}
```

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
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.3 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `null` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name, URL, or local path. Required only when create is true. | `string` | `null` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to manage this Helm release. False removes an existing managed release. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not exist | `bool` | `null` | no |
| <a name="input_default_values"></a> [default\_values](#input\_default\_values) | Low-priority YAML defaults for composition by catalogs. Service-account settings, values\_object, values, and set overrides take precedence, in that order. | `list(string)` | `[]` | no |
| <a name="input_dependency_update"></a> [dependency\_update](#input\_dependency\_update) | Run helm dependency update before installing the chart | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Add a custom description | `string` | `null` | no |
| <a name="input_devel"></a> [devel](#input\_devel) | Use chart development versions, too. Equivalent to version '>0.0.0-0'. If 'version' is set, this is ignored | `bool` | `null` | no |
| <a name="input_disable_crd_hooks"></a> [disable\_crd\_hooks](#input\_disable\_crd\_hooks) | Prevent CRD hooks from running, but run other hooks. See helm install --no-crd-hook | `bool` | `null` | no |
| <a name="input_disable_openapi_validation"></a> [disable\_openapi\_validation](#input\_disable\_openapi\_validation) | If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema | `bool` | `null` | no |
| <a name="input_disable_webhooks"></a> [disable\_webhooks](#input\_disable\_webhooks) | Prevent hooks from running | `bool` | `null` | no |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Force resource update through delete/recreate if needed. | `bool` | `null` | no |
| <a name="input_keyring"></a> [keyring](#input\_keyring) | Location of public keys used for verification, Used only if 'verify is true' | `string` | `null` | no |
| <a name="input_lint"></a> [lint](#input\_lint) | Run helm lint when planning | `bool` | `null` | no |
| <a name="input_max_history"></a> [max\_history](#input\_max\_history) | Limit the maximum number of revisions saved per release. Use 0 for no limit | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Release name, at most 53 characters. Required only when create is true. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install the release into | `string` | `null` | no |
| <a name="input_pass_credentials"></a> [pass\_credentials](#input\_pass\_credentials) | Pass credentials to all domains | `bool` | `null` | no |
| <a name="input_postrender"></a> [postrender](#input\_postrender) | Postrender command config | ```object({ args = optional(list(string)) binary_path = string })``` | `null` | no |
| <a name="input_recreate_pods"></a> [recreate\_pods](#input\_recreate\_pods) | Perform pods restart during upgrade/rollback | `bool` | `null` | no |
| <a name="input_render_subchart_notes"></a> [render\_subchart\_notes](#input\_render\_subchart\_notes) | If set, render subchart notes along with the parent | `bool` | `null` | no |
| <a name="input_replace"></a> [replace](#input\_replace) | Re-use the given name, even if that name is already used. This is unsafe in production | `bool` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository where to locate the requested chart. If it is a URL, the chart is installed without installing the repository | `string` | `null` | no |
| <a name="input_repository_ca_file"></a> [repository\_ca\_file](#input\_repository\_ca\_file) | The Repositories CA file | `string` | `null` | no |
| <a name="input_repository_cert_file"></a> [repository\_cert\_file](#input\_repository\_cert\_file) | The repositories cert file | `string` | `null` | no |
| <a name="input_repository_key_file"></a> [repository\_key\_file](#input\_repository\_key\_file) | The repositories cert key file | `string` | `null` | no |
| <a name="input_repository_password"></a> [repository\_password](#input\_repository\_password) | Password for HTTP basic authentication | `string` | `null` | no |
| <a name="input_repository_username"></a> [repository\_username](#input\_repository\_username) | Username for HTTP basic authentication | `string` | `null` | no |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | When upgrading, reset the values to the ones built into the chart | `bool` | `null` | no |
| <a name="input_reuse_values"></a> [reuse\_values](#input\_reuse\_values) | When upgrading, reuse the last release's values and merge in any overrides. If 'reset\_values' is specified, this is ignored | `bool` | `null` | no |
| <a name="input_service_account_paths"></a> [service\_account\_paths](#input\_service\_account\_paths) | Role -> field -> chart key segments. Supported fields: name, create, annotations, labels, pod\_labels. Segments are literal keys, so dots/slashes need no Helm escaping. Omit unsupported fields. | `map(map(list(string)))` | `{}` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Chart-side service-account and workload identity settings keyed by logical role. Each populated field needs an explicit service\_account\_paths mapping. Does not create cloud identities or separate Kubernetes resources. | ```map(object({ name = optional(string) create = optional(bool) annotations = optional(map(string), {}) labels = optional(map(string), {}) pod_labels = optional(map(string), {}) }))``` | `{}` | no |
| <a name="input_set"></a> [set](#input\_set) | Custom values to be merged with the values | ```list(object({ name = string type = optional(string) value = optional(string) }))``` | `[]` | no |
| <a name="input_set_list"></a> [set\_list](#input\_set\_list) | List-valued Helm overrides | ```list(object({ name = string value = list(string) }))``` | `[]` | no |
| <a name="input_set_sensitive"></a> [set\_sensitive](#input\_set\_sensitive) | Custom sensitive values to be merged with the values | ```list(object({ name = string type = optional(string) value = string }))``` | `[]` | no |
| <a name="input_set_wo"></a> [set\_wo](#input\_set\_wo) | Write-only Helm overrides. Increment set\_wo\_revision on changes. Ephemeral inputs are not retained in Terraform state; Helm still persists release data in Kubernetes. | ```list(object({ name = string type = optional(string) value = string }))``` | `null` | no |
| <a name="input_set_wo_revision"></a> [set\_wo\_revision](#input\_set\_wo\_revision) | The current revision of the write-only "set\_wo" attribute. Incrementing this integer value will cause Terraform to update the write-only value. | `number` | `null` | no |
| <a name="input_skip_crds"></a> [skip\_crds](#input\_skip\_crds) | If set, no CRDs will be installed. By default, CRDs are installed if not already present | `bool` | `null` | no |
| <a name="input_take_ownership"></a> [take\_ownership](#input\_take\_ownership) | If set, Helm will take ownership of resources not already annotated by this release. Useful for migrations or recovery. | `bool` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation | `number` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Terraform provider operation timeouts, separate from the Helm timeout in seconds. | ```object({ create = optional(string) delete = optional(string) read = optional(string) update = optional(string) })``` | `null` | no |
| <a name="input_upgrade_install"></a> [upgrade\_install](#input\_upgrade\_install) | If true, the provider will install the release at the specified version even if a release not controlled by the provider is present. This is equivalent to running 'helm upgrade --install'. WARNING: this may not be suitable for production use -- see the 'Upgrade Mode' note in the provider documentation. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_values"></a> [values](#input\_values) | List of values in raw YAML format to pass to helm | `list(string)` | `[]` | no |
| <a name="input_values_object"></a> [values\_object](#input\_values\_object) | A native HCL object/map encoded as YAML before values. Nested types are preserved; Helm performs the merge. Ordinary values remain in state. | `any` | `null` | no |
| <a name="input_verify"></a> [verify](#input\_verify) | Verify the package before installing it. | `bool` | `null` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. | `bool` | `null` | no |
| <a name="input_wait_for_jobs"></a> [wait\_for\_jobs](#input\_wait\_for\_jobs) | If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. | `bool` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_chart"></a> [chart](#output\_chart) | Helm release chart, or null when disabled. |
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Helm release chart version, or null when disabled. |
| <a name="output_id"></a> [id](#output\_id) | Helm release id, or null when disabled. |
| <a name="output_manifest"></a> [manifest](#output\_manifest) | Helm release manifest, or null when disabled. |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Helm release metadata, or null when disabled. |
| <a name="output_name"></a> [name](#output\_name) | Helm release name, or null when disabled. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Helm release namespace, or null when disabled. |
| <a name="output_resources"></a> [resources](#output\_resources) | Helm release resources, or null when disabled. |
| <a name="output_status"></a> [status](#output\_status) | Helm release status, or null when disabled. |
<!-- END_TF_DOCS -->

### 🔃 Contributing

Refer to our [documentation for contributors][contributing] for development checks, native tests,
commit message formats, and versioning tips.

### 📥 Maintainers

This project is owned and maintained by [Ad Noctem Collective][org].
Refer to the [`AUTHORS`][authors] or [`CODEOWNERS`][owners] for more information.
You may also use the linked contact details to reach out directly.

### ©️ Copyright

- _Assets provided by:_ **[HashiCorp][hashicorp]**
- _Sources provided by:_ **[Ad Noctem Collective][org]** under the **[MIT License][license]**

<!-- File references -->

[license]: LICENSE
[contributing]: docs/CONTRIBUTING.md
[authors]: .github/AUTHORS
[owners]: .github/CODEOWNERS

<!-- General links -->

[org]: https://github.com/adnoctem
[terraform]: https://terraform.io
[opentofu]: https://opentofu.org/
[hashicorp]: https://www.hashicorp.com/
[github_releases]: https://github.com/adnoctem/terraform-helm-release/releases
[github_commits]: https://github.com/adnoctem/terraform-helm-release/commits/main/

<!-- Third-party -->

[module]: https://registry.terraform.io/modules/adnoctem/release/helm/latest
[renovate]: https://renovatebot.com/
[pre-commit]: https://pre-commit.com/
