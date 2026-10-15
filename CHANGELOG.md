## [2.0.0](https://github.com/adnoctem/terraform-helm-release/compare/v1.0.0...v2.0.0) (2026-10-15)

### ⚠ BREAKING CHANGES

* **module:** replace the releases map with one release per module call.
Require Terraform/OpenTofu 1.11 and Helm provider 3.3. Move provider settings
to the caller and follow docs/UPGRADING.md before migrating existing state.

### Features

* **module:** add structured values and account mapping helpers ([0705621](https://github.com/adnoctem/terraform-helm-release/commit/0705621313de3bccfd0da204064cbd41f768053a))
* **module:** manage individual Helm releases ([4401a8e](https://github.com/adnoctem/terraform-helm-release/commit/4401a8eb3dfd3a5c67ec37fc4ae92072e1f53eb7))

## 1.0.0 (2025-11-14)

### Features

* add `v1.0.0` module sources ([6b4cb1d](https://github.com/adnoctem/terraform-helm-releases/commit/6b4cb1dd5e14e99916c78f9a7c7f02d306aa0a9f))
* initial release `v1.0.0` ([e790bc2](https://github.com/adnoctem/terraform-helm-releases/commit/e790bc2cb86821275954b6a3f6bd2fa7b8a2106d))

### Bug Fixes

* update invalid secret reference ([7ef5e77](https://github.com/adnoctem/terraform-helm-releases/commit/7ef5e771d26dde1b09c1ac0b720cec435434c26e))
* update workflow secret name ([fb71e8f](https://github.com/adnoctem/terraform-helm-releases/commit/fb71e8fe0684205b27664a0d8e4f3617b0d49edc))
