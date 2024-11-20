## 8.0.0 (2024-11-20)

### ⚠ BREAKING CHANGES

* **AZ-1088:** module v8 structure and updates

### Features

* **AZ-1088:** module v8 structure and updates 8afc2db

### Miscellaneous Chores

* **deps:** update dependency claranet/diagnostic-settings/azurerm to v7 b6c285f
* **deps:** update dependency opentofu to v1.8.3 ea2d29c
* **deps:** update dependency opentofu to v1.8.4 5691497
* **deps:** update dependency pre-commit to v4 22f452f
* **deps:** update dependency pre-commit to v4.0.1 fedfb0f
* **deps:** update dependency tflint to v0.54.0 4b892fc
* **deps:** update dependency trivy to v0.56.1 df68b0a
* **deps:** update dependency trivy to v0.56.2 c11d626
* **deps:** update dependency trivy to v0.57.1 0fe9f7b
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v5 255b5ba
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.1.0 39b93f8
* **deps:** update tools 3a29850
* prepare for new examples structure 961a1ca
* update examples structure b5ab71c

## 7.6.0 (2024-10-03)

### Features

* use Claranet "azurecaf" provider fca3a26

### Documentation

* update README badge to use OpenTofu registry 7fbcc12
* update README with `terraform-docs` v0.19.0 65f0d50

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.8.1 907f92a
* **deps:** update dependency opentofu to v1.8.2 53f5865
* **deps:** update dependency terraform-docs to v0.19.0 94ca552
* **deps:** update dependency tflint to v0.53.0 141bae1
* **deps:** update dependency trivy to v0.55.0 d5a5c57
* **deps:** update dependency trivy to v0.55.1 ed997ba
* **deps:** update dependency trivy to v0.55.2 60dc61b
* **deps:** update dependency trivy to v0.56.0 dd2c7e9
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.17.0 dd299fc
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.18.0 a6bac64
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.2 b0deb48
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.3 ea14524
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.93.0 0cce081
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.0 90f51a9
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.1 cfd2148
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.2 b08d90d
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.3 4928e04
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.95.0 6faf214
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.0 2ffcd92
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.1 7ad6f18

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
