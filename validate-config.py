#!/usr/bin/env python3
import json
import yaml

# Test CloudWatch Agent config
cw_config = {
    "agent": {},
    "traces": {
        "traces_collected": {
            "otlp": {
                "bind_address": "0.0.0.0:4318"
            }
        }
    },
    "metrics": {
        "metrics_collected": {
            "prometheus": {
                "prometheus_config_path": "/opt/aws/amazon-cloudwatch-agent/etc/prometheus.yaml"
            }
        },
        "namespace": "ContainerInsights/Prometheus"
    }
}

# Test Prometheus config
prometheus_config = {
    "global": {
        "scrape_interval": "1m",
        "scrape_timeout": "10s"
    },
    "scrape_configs": [
        {
            "job_name": "application-metrics",
            "static_configs": [
                {
                    "targets": ["localhost:8080"]
                }
            ],
            "metrics_path": "/actuator/prometheus"
        }
    ],
    "remote_write": [
        {
            "url": "https://aps-workspaces.us-west-2.amazonaws.com/workspaces/ws-12345/api/v1/remote_write",
            "sigv4": {
                "region": "us-west-2"
            }
        }
    ]
}

print("CloudWatch Agent Config:")
print(json.dumps(cw_config, indent=2))
print("\nPrometheus Config:")
print(yaml.dump(prometheus_config, default_flow_style=False))
print("\nConfigs are valid JSON/YAML")