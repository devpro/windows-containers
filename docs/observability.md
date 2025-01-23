# Observability

## OpenTelemetry

Add Helm repository ([source](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)):

```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```

Create the configuration file (ref. [values.yaml](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml)):

```bash
cat <<EOF > otel_values.yaml
# daemonset is not possible as no image available for Windows (maybe in the future with https://github.com/open-telemetry/opentelemetry-collector-releases/issues/339)
mode: deployment
replicaCount: 1
nodeSelector:
  kubernetes.io/os: linux
image:
  # https://hub.docker.com/r/otel/opentelemetry-collector-k8s/tags
  repository: otel/opentelemetry-collector-k8s
  # https://github.com/open-telemetry/opentelemetry-collector-releases/pkgs/container/opentelemetry-collector-releases%2Fopentelemetry-collector
  repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector
command:
  name: otelcol-k8s
resources:
  limits:
    cpu: 250m
    memory: 512Mi
config:
  exporters:
    debug/detailed:
      verbosity: detailed
    debug/normal:
      verbosity: normal
  receivers:
    jaeger: null
    prometheus: null
    zipkin: null
  service:
    pipelines:
      logs:
        exporters:
          - debug/normal
        processors:
          - memory_limiter
          - batch
        receivers:
          - otlp
      metrics:
        exporters:
          - debug/detailed
        processors:
          - memory_limiter
          - batch
        receivers:
          - otlp
          # - prometheus
      traces:
        exporters:
          - debug/normal
        processors:
          - memory_limiter
          - batch
        receivers:
          - otlp
ports:
  jaeger-compact:
    enabled: false
  jaeger-thrift:
    enabled: false
  jaeger-grpc:
    enabled: false
  zipkin:
    enabled: false
EOF
```

Install the application with Helm:

```bash
helm upgrade --install opentelemetry-collector open-telemetry/opentelemetry-collector -f otel_values.yaml --namespace opentelemetry-collector --create-namespace
```

Watches the installation and checks all pods are running after some time:

```bash
kubectl get pod -n opentelemetry-collector --watch
```
