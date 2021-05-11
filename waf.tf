resource "aws_wafv2_ip_set" "ipset" {
  count              = var.wafv2_enable ? 1 : 0
  name               = "${var.name}-tfIPSet"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = split(",", var.ip_allowlist)
}


resource "aws_wafv2_web_acl" "waf_apigateway" {
  count       = var.wafv2_enable ? 1 : 0
  name        = "${var.name}-waf_apigateway"
  description = "WAF with ip whitelist rule"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "ipwhitelist"
    priority = 0

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipset[count.index].arn
        ip_set_forwarded_ip_config {
          fallback_behavior = "MATCH"
          header_name       = "SourceIP"
          position          = "FIRST"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-ipwhitelist"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Name = "${var.name}-waf_apigateway"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-general"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "waf_alb_association" {
  count        = var.wafv2_enable ? 1 : 0
  resource_arn = aws_api_gateway_stage.prod.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_apigateway[count.index].arn
}

