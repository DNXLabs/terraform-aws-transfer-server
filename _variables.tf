variable "name" {
  description = "name of SFTP Server"
}

variable "dynamo_table_name" {
  default = "my-sftp-authentication-table"
}

variable "creds_store" {
  default     = "secrets"
  description = "dynamo for dynamodb/ secrets for secret manager"
}

variable "ip_allowlist" {
  #type        = list(string)
  description = "List of IPs to allow on WAF and IAM Policies"
}

variable "wafv2_enable" {
  type    = bool
  default = false
}

variable "endpoint_type" {
  default     = "PUBLIC"
  description = "PUBLIC or VPC"
}

variable "vpc_id" {
  description = "VPC ID to deploy the SFTP cluster."
}


variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for VPC Endpoint."
}

variable "address_allocation_ids" {
  type        = list(string)
  description = "List of Elastic IPs Allocation IDs to attach to VPC Endpoint."
}

variable "password" {
  type        = string
  description = "Password for test user"
}

variable "public_key" {
  type        = string
  description = "SSH Public Key for test user"
}

variable "custom_domain" {
  type        = string
  description = "custom DNS name for SFTP transfer server endpoint"
}

variable "aws_route53_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_role" {
  type        = string
  description = "IAM Role"
}