resource "aws_prometheus_workspace" "this" {
  alias = "${var.environment_name}-prometheus"
  tags  = var.tags
}

resource "aws_grafana_workspace" "this" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn
  name                     = "${var.environment_name}-grafana"
  description              = "Grafana workspace for ${var.environment_name}"
  data_sources             = ["PROMETHEUS"]
  tags                     = var.tags
}

resource "aws_iam_role" "grafana" {
  name = "${var.environment_name}-grafana-role"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess"
  role       = aws_iam_role.grafana.name
}

resource "aws_iam_policy" "grafana_amp" {
  name = "${var.environment_name}-grafana-amp"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_amp" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_amp.arn
}

resource "aws_iam_policy" "amp_remote_write" {
  name        = "${var.environment_name}-amp-remote-write"
  description = "Policy for writing metrics to AMP"
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.this.arn
      }
    ]
  })
}