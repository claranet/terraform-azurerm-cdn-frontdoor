## 7.5.0 (2024-08-02)


### Features

* **AZ-1444:** support of AFD certificates 14ff9ef


### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.7.3 71637fd
* **deps:** update dependency opentofu to v1.8.0 8fcd7fe
* **deps:** update dependency pre-commit to v3.8.0 ee95289
* **deps:** update dependency tflint to v0.51.2 2997b00
* **deps:** update dependency tflint to v0.52.0 12bb82f
* **deps:** update dependency trivy to v0.52.2 787e211
* **deps:** update dependency trivy to v0.53.0 517650e
* **deps:** update dependency trivy to v0.54.1 603f8e7
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.0 b3d3316
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.1 8548f8f

## 7.4.0 (2024-06-14)


### Features

* add resource azurerm_cdn_frontdoor_secret; add option var custom_domains.key_vault_certificate_id 91667ab


### Bug Fixes

* fix example 9b01b2a


### Continuous Integration

* **AZ-1391:** enable semantic-release [skip ci] 6c39e21
* **AZ-1391:** update semantic-release config [skip ci] cdf696f


### Miscellaneous Chores

* **deps:** enable automerge on renovate e95f24e
* **deps:** update dependency opentofu to v1.7.0 6bb06ba
* **deps:** update dependency opentofu to v1.7.1 d0fe301
* **deps:** update dependency opentofu to v1.7.2 c68ba50
* **deps:** update dependency pre-commit to v3.7.1 d7bcdf6
* **deps:** update dependency terraform-docs to v0.18.0 1e0f28e
* **deps:** update dependency tflint to v0.51.0 691397f
* **deps:** update dependency tflint to v0.51.1 38fa201
* **deps:** update dependency trivy to v0.50.2 e5ec4ee
* **deps:** update dependency trivy to v0.50.4 3a4eb9e
* **deps:** update dependency trivy to v0.51.0 6a427e9
* **deps:** update dependency trivy to v0.51.1 5a5ef01
* **deps:** update dependency trivy to v0.51.2 57f7e88
* **deps:** update dependency trivy to v0.51.3 6c05209
* **deps:** update dependency trivy to v0.51.4 4540053
* **deps:** update dependency trivy to v0.52.0 96e15b7
* **deps:** update dependency trivy to v0.52.1 53651f4
* **pre-commit:** update commitlint hook 95901b5
* ran terraform-docs 9c90264
* **release:** remove legacy `VERSION` file 805768a
* update example for custom domains e69b647

# v7.3.0 - 2024-04-05

Changed
  * [GH-3](https://github.com/claranet/terraform-azurerm-cdn-frontdoor/pull/3): Bump diagnostic settings version to 6.5.0

# v7.2.0 - 2023-04-07

Breaking
  * AZ-1048: Rework `rule_sets` rules definition

# v7.1.1 - 2023-03-10

Fixed
  * AZ-1024: Fix Cache Query string is a list of strings

# v7.1.0 - 2022-12-09

Added
  * AZ-918: Add `azurerm_cdn_frontdoor_security_policy` resource

Changed
  * AZ-918: Bump `azurerm` version
  * AZ-918: Rename resources to match documentation

# v7.0.0 - 2022-11-25

Added
  * AZ-829: Azure CDN FrontDoor - First Release
