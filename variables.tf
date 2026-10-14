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
  description = "Chart name to be installed. A path may be used"
  nullable    = false
  validation {
    condition     = length(trimspace(var.chart)) > 0
    error_message = "chart must not be empty."
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
}

variable "name" {
  type        = string
  description = "Release name. The length must not be longer than 53 characters"
  nullable    = false
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
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
}

variable "set_list" {
  type = list(object({
    name  = string
    value = list(string)
  }))
  description = "Custom sensitive values to be merged with the values"
  default     = []
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
}

variable "set_wo_revision" {
  type        = number
  description = "The current revision of the write-only \"set_wo\" attribute. Incrementing this integer value will cause Terraform to update the write-only value."
  default     = null
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
