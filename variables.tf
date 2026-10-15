variable "create" {
  type        = bool
  default     = true
  nullable    = false
  description = "Whether to manage this Helm release. False removes an existing managed release."
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
  default     = null
}

variable "chart" {
  type        = string
  default     = null
  description = "Chart name, URL, or local path. Required only when create is true."
  validation {
    condition     = !var.create || try(length(trimspace(var.chart)) > 0, false)
    error_message = "When create=true, chart must not be null or empty."
  }
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  default     = null
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace if it does not exist"
  default     = null
}

variable "dependency_update" {
  type        = bool
  description = "Run helm dependency update before installing the chart"
  default     = null
}

variable "description" {
  type        = string
  description = "Add a custom description"
  default     = null
}

variable "devel" {
  type        = bool
  description = "Use chart development versions, too. Equivalent to version '>0.0.0-0'. If 'version' is set, this is ignored"
  default     = null
}

variable "disable_crd_hooks" {
  type        = bool
  description = "Prevent CRD hooks from running, but run other hooks. See helm install --no-crd-hook"
  default     = null
}

variable "disable_openapi_validation" {
  type        = bool
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema"
  default     = null
}

variable "disable_webhooks" {
  type        = bool
  description = "Prevent hooks from running"
  default     = null
}

variable "force_update" {
  type        = bool
  description = "Force resource update through delete/recreate if needed."
  default     = null
}

variable "keyring" {
  type        = string
  description = "Location of public keys used for verification, Used only if 'verify is true'"
  default     = null
}

variable "lint" {
  type        = bool
  description = "Run helm lint when planning"
  default     = null
}

variable "max_history" {
  type        = number
  description = "Limit the maximum number of revisions saved per release. Use 0 for no limit"
  default     = null
  validation {
    condition     = var.max_history == null ? true : var.max_history >= 0 && floor(var.max_history) == var.max_history
    error_message = "max_history must be a nonnegative whole number; zero means unlimited."
  }
}

variable "name" {
  type        = string
  default     = null
  description = "Release name, at most 53 characters. Required only when create is true."
  validation {
    condition     = !var.create || try(length(var.name) <= 53 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?([.][a-z0-9]([-a-z0-9]*[a-z0-9])?)*$", var.name)), false)
    error_message = "When create=true, name must be a lowercase Helm release name of 1-53 characters."
  }
}

variable "namespace" {
  type        = string
  description = "Namespace to install the release into"
  default     = null
}

variable "pass_credentials" {
  type        = bool
  description = "Pass credentials to all domains"
  default     = null
}

variable "postrender" {
  type = object({
    args        = optional(list(string))
    binary_path = string
  })
  description = "Postrender command config"
  default     = null
}

variable "recreate_pods" {
  type        = bool
  description = "Perform pods restart during upgrade/rollback"
  default     = null
}

variable "render_subchart_notes" {
  type        = bool
  description = "If set, render subchart notes along with the parent"
  default     = null
}

variable "replace" {
  type        = bool
  description = "Re-use the given name, even if that name is already used. This is unsafe in production"
  default     = null
}

variable "repository" {
  type        = string
  description = "Repository where to locate the requested chart. If it is a URL, the chart is installed without installing the repository"
  default     = null
}

variable "repository_ca_file" {
  type        = string
  description = "The Repositories CA file"
  default     = null
}

variable "repository_cert_file" {
  type        = string
  description = "The repositories cert file"
  default     = null
}

variable "repository_key_file" {
  type        = string
  description = "The repositories cert key file"
  default     = null
}

variable "repository_password" {
  type        = string
  description = "Password for HTTP basic authentication"
  default     = null
  sensitive   = true
}

variable "repository_username" {
  type        = string
  description = "Username for HTTP basic authentication"
  default     = null
}

variable "reset_values" {
  type        = bool
  description = "When upgrading, reset the values to the ones built into the chart"
  default     = null
}

variable "reuse_values" {
  type        = bool
  description = "When upgrading, reuse the last release's values and merge in any overrides. If 'reset_values' is specified, this is ignored"
  default     = null
}

variable "set" {
  type = list(object({
    name  = string
    type  = optional(string)
    value = optional(string)
  }))
  description = "Custom values to be merged with the values"
  default     = []
  nullable    = false
  validation {
    condition     = try(alltrue([for item in var.set : try(length(trimspace(item.name)) > 0, false)]) && alltrue([for item in var.set : item.type == null ? true : contains(["auto", "string", "literal"], item.type)]), false)
    error_message = "set entries need a nonempty name and a supported type."
  }
}

variable "set_list" {
  type = list(object({
    name  = string
    value = list(string)
  }))
  description = "List-valued Helm overrides"
  default     = []
  nullable    = false
  validation {
    condition     = try(alltrue([for item in var.set_list : try(length(trimspace(item.name)) > 0, false)]), false)
    error_message = "set_list entries need a nonempty name."
  }
}

variable "set_sensitive" {
  type = list(object({
    name  = string
    type  = optional(string)
    value = string
  }))
  description = "Custom sensitive values to be merged with the values"
  default     = []
  sensitive   = true
  nullable    = false
  validation {
    condition     = try(alltrue([for item in var.set_sensitive : try(length(trimspace(item.name)) > 0, false)]) && alltrue([for item in var.set_sensitive : item.type == null ? true : contains(["auto", "string", "literal"], item.type)]), false)
    error_message = "set_sensitive entries need a nonempty name and a supported type."
  }
  validation {
    condition     = try(length(var.set) + length(var.set_list) + length(var.set_sensitive) == length(distinct(concat(var.set[*].name, var.set_list[*].name, var.set_sensitive[*].name))), false)
    error_message = "Override paths must be unique across set, set_list, and set_sensitive."
  }
}

variable "set_wo" {
  type = list(object({
    name  = string
    type  = optional(string)
    value = string
  }))
  description = "Write-only Helm overrides. Increment set_wo_revision on changes. Ephemeral inputs are not retained in Terraform state; Helm still persists release data in Kubernetes."
  default     = null
  sensitive   = true
  ephemeral   = true
  validation {
    condition     = try(alltrue([for item in(var.set_wo == null ? [] : var.set_wo) : try(length(trimspace(item.name)) > 0, false)]) && alltrue([for item in(var.set_wo == null ? [] : var.set_wo) : item.type == null ? true : contains(["auto", "string"], item.type)]), false)
    error_message = "set_wo entries need a nonempty name and a supported type."
  }
  validation {
    condition = var.set_wo == null ? true : (
      length(var.set_wo) == length(distinct(var.set_wo[*].name)) &&
      length(setintersection(toset(var.set_wo[*].name), toset(concat(var.set[*].name, var.set_list[*].name, var.set_sensitive[*].name)))) == 0
    )
    error_message = "Write-only override paths must be unique and must not also occur in other set collections."
  }
  validation {
    condition     = try(var.set_wo == null ? true : length(var.set_wo) == 0 || var.set_wo_revision != null, false)
    error_message = "Provide set_wo_revision with write-only values, and increment it when they change."
  }
}

variable "set_wo_revision" {
  type        = number
  description = "The current revision of the write-only \"set_wo\" attribute. Incrementing this integer value will cause Terraform to update the write-only value."
  default     = null
  validation {
    condition     = var.set_wo_revision == null ? true : var.set_wo_revision >= 1 && floor(var.set_wo_revision) == var.set_wo_revision
    error_message = "set_wo_revision must be a positive whole number when provided."
  }
}

variable "skip_crds" {
  type        = bool
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present"
  default     = null
}

variable "take_ownership" {
  type        = bool
  description = "If set, Helm will take ownership of resources not already annotated by this release. Useful for migrations or recovery."
  default     = null
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation"
  default     = null
  validation {
    condition     = var.timeout == null ? true : var.timeout > 0 && floor(var.timeout) == var.timeout
    error_message = "timeout must be a positive whole number of seconds."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  description = "Terraform provider operation timeouts, separate from the Helm timeout in seconds."
  default     = null
}

variable "upgrade_install" {
  type        = bool
  description = "If true, the provider will install the release at the specified version even if a release not controlled by the provider is present. This is equivalent to running 'helm upgrade --install'. WARNING: this may not be suitable for production use -- see the 'Upgrade Mode' note in the provider documentation. Defaults to `false`."
  default     = null
}

variable "values" {
  type        = list(string)
  description = "List of values in raw YAML format to pass to helm"
  default     = []
  sensitive   = true
  nullable    = false
}

variable "verify" {
  type        = bool
  description = "Verify the package before installing it."
  default     = null
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  default     = null
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful."
  default     = null
}

variable "wait_for_jobs" {
  type        = bool
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful."
  default     = null
}


variable "default_values" {
  type        = list(string)
  default     = []
  nullable    = false
  sensitive   = true
  description = "Low-priority YAML defaults for composition by catalogs. Service-account settings, values_object, values, and set overrides take precedence, in that order."
}

variable "values_object" {
  type        = any
  default     = null
  sensitive   = true
  description = "A native HCL object/map encoded as YAML before values. Nested types are preserved; Helm performs the merge. Ordinary values remain in state."
  validation {
    condition     = var.values_object == null ? true : can(keys(var.values_object))
    error_message = "values_object must be an object/map or null, not a scalar or list."
  }
}

variable "service_accounts" {
  type = map(object({
    name        = optional(string)
    create      = optional(bool)
    annotations = optional(map(string), {})
    labels      = optional(map(string), {})
    pod_labels  = optional(map(string), {})
  }))
  default     = {}
  nullable    = false
  description = "Chart-side service-account and workload identity settings keyed by logical role. Each populated field needs an explicit service_account_paths mapping. Does not create cloud identities or separate Kubernetes resources."
  validation {
    condition     = try(length(var.service_accounts) == 0 || alltrue(flatten([for role, account in var.service_accounts : [for field, value in account : length(lookup(lookup(var.service_account_paths, role, {}), field, [])) > 0 if value != null && jsonencode(value) != "{}"]])), false)
    error_message = "Each populated service-account field needs a nonempty service_account_paths mapping for its role. This chart may not expose that field."
  }
  validation {
    condition     = try(length(var.service_accounts) == 0 || length(flatten([for role, account in var.service_accounts : [for field, value in account : jsonencode(lookup(lookup(var.service_account_paths, role, {}), field, [])) if value != null && jsonencode(value) != "{}"]])) == length(distinct(flatten([for role, account in var.service_accounts : [for field, value in account : jsonencode(lookup(lookup(var.service_account_paths, role, {}), field, [])) if value != null && jsonencode(value) != "{}"]]))), false)
    error_message = "Service-account fields must not target the same chart value path."
  }
  validation {
    condition     = try(alltrue([for account in var.service_accounts : account.name == null ? true : length(trimspace(account.name)) > 0]), false)
    error_message = "Explicit service-account names must not be empty."
  }
}

variable "service_account_paths" {
  type        = map(map(list(string)))
  default     = {}
  nullable    = false
  description = "Role -> field -> chart key segments. Supported fields: name, create, annotations, labels, pod_labels. Segments are literal keys, so dots/slashes need no Helm escaping. Omit unsupported fields."
  validation {
    condition     = try(alltrue(flatten([for fields in var.service_account_paths : [for field, path in fields : contains(["name", "create", "annotations", "labels", "pod_labels"], field) && alltrue([for segment in path : length(trimspace(segment)) > 0])]])), false)
    error_message = "Service-account mappings must use supported field names and nonempty path segments."
  }
}
