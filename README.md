# terraform-aws-transfer-server

# SFTP Diagram

![image](Docs/SFTP-HLD.jpg)

[![Lint Status](https://github.com/DNXLabs/terraform-aws-transfer-server/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-transfer-server/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-transfer-server)](https://github.com/DNXLabs/terraform-aws-transfer-server/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| archive | n/a |
| aws | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_allocation\_ids | List of Elastic IPs Allocation IDs to attach to VPC Endpoint. | `list(string)` | n/a | yes |
| aws\_route53\_id | Route53 Hosted Zone ID | `string` | n/a | yes |
| creds\_store | dynamo for dynamodb/ secrets for secret manager | `string` | `"secrets"` | no |
| custom\_domain | custom DNS name for SFTP transfer server endpoint | `string` | n/a | yes |
| dynamo\_table\_name | n/a | `string` | `"my-sftp-authentication-table"` | no |
| endpoint\_type | PUBLIC or VPC | `string` | `"PUBLIC"` | no |
| ip\_allowlist | List of IPs to allow on WAF and IAM Policies | `any` | n/a | yes |
| name | name of SFTP Server | `any` | n/a | yes |
| password | Password for test user | `string` | n/a | yes |
| public\_key | SSH Public Key for test user | `string` | n/a | yes |
| public\_subnet\_ids | List of public subnet IDs for VPC Endpoint. | `list(string)` | n/a | yes |
| vpc\_id | VPC ID to deploy the SFTP cluster. | `any` | n/a | yes |
| wafv2\_enable | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | n/a |
| invoke\_url | n/a |
| rest\_api\_id | n/a |
| rest\_api\_stage\_name | n/a |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-transfer-server/blob/master/LICENSE) for full details.