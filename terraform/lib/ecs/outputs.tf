output "ui_service_url" {
  description = "URL of the UI component"
  value       = "http://${module.alb.lb_dns_name}"
}

output "catalog_security_group_id" {
  value       = module.catalog_service.task_security_group_id
  description = "Security group ID of the catalog service"
}

output "checkout_security_group_id" {
  value       = module.checkout_service.task_security_group_id
  description = "Security group ID of the checkout service"
}

output "orders_security_group_id" {
  value       = module.orders_service.task_security_group_id
  description = "Security group ID of the orders service"
}

output "amp_workspace_id" {
  value       = aws_prometheus_workspace.this.id
  description = "AMP workspace ID"
}

output "amp_workspace_endpoint" {
  value       = aws_prometheus_workspace.this.prometheus_endpoint
  description = "AMP workspace endpoint"
}

output "grafana_workspace_id" {
  value       = aws_grafana_workspace.this.id
  description = "Grafana workspace ID"
}

output "grafana_workspace_endpoint" {
  value       = aws_grafana_workspace.this.endpoint
  description = "Grafana workspace endpoint"
}
