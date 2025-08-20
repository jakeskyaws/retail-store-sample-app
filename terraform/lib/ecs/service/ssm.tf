locals {
  cw_config = {
    receivers = {
      awsecscontainermetrics = {
        collection_interval = "30s"
      }
      otlp = {
        protocols = {
          grpc = {
            endpoint = "0.0.0.0:4317"
          }
          http = {
            endpoint = "0.0.0.0:4318"
          }
        }
      }
    }
    processors = {
      batch = {}
    }
    exporters = {
      prometheusremotewrite = {
        endpoint = var.amp_workspace_endpoint
        auth = {
          authenticator = "sigv4auth"
        }
      }
      awsxray = {
        region = data.aws_region.current.name
      }
    }
    extensions = {
      sigv4auth = {
        region = data.aws_region.current.name
      }
    }
    service = {
      extensions = ["sigv4auth"]
      pipelines = {
        metrics = {
          receivers = ["awsecscontainermetrics"]
          processors = ["batch"]
          exporters = ["prometheusremotewrite"]
        }
        traces = {
          receivers = ["otlp"]
          processors = ["batch"]
          exporters = ["awsxray"]
        }
      }
    }
  }
  
  prometheus_config = {
    global = {
      scrape_interval = "1m"
    }
    scrape_configs = [
      {
        job_name = "app"
        static_configs = [
          {
            targets = ["localhost:8080"]
            labels = {
              service = var.service_name
              cluster = var.environment_name
              platform = "ecs-fargate"
              region = data.aws_region.current.name
            }
          }
        ]
        metrics_path = contains(["ui", "cart", "orders"], var.service_name) ? "/actuator/prometheus" : "/metrics"
      },
      {
        job_name = "ecs-task-metadata"
        static_configs = [
          {
            targets = ["169.254.170.2:80"]
            labels = {
              service = var.service_name
              cluster = var.environment_name
              platform = "ecs-fargate"
              region = data.aws_region.current.name
            }
          }
        ]
        metrics_path = "/v4/stats"
        scrape_interval = "30s"
        metric_relabel_configs = [
          {
            source_labels = ["__name__"]
            regex = "container_.*"
            target_label = "__name__"
            replacement = "ecs_${1}"
          }
        ]
      }
    ]
    remote_write = [
      {
        url = var.amp_workspace_endpoint
        sigv4 = {
          region = data.aws_region.current.name
        }
      }
    ]
  }
}

resource "aws_ssm_parameter" "cw_config" {
  count       = var.opentelemetry_enabled ? 1 : 0
  name        = "/${var.environment_name}/${var.service_name}/cloudwatch-agent/config"
  type        = "String"
  description = "OpenTelemetry Collector config for ${var.service_name} - includes awscontainerinsightreceiver, traces (OTLP), and AMP integration"
  value       = jsonencode(local.cw_config)
  tags        = var.tags
}

# Prometheus config disabled - using awscontainerinsightreceiver instead
# resource "aws_ssm_parameter" "prometheus_config" {
#   count       = var.opentelemetry_enabled ? 1 : 0
#   name        = "/${var.environment_name}/${var.service_name}/prometheus/config"
#   type        = "String"
#   description = "Prometheus config for ${var.service_name}"
#   value       = yamlencode(local.prometheus_config)
#   tags        = var.tags
# }

