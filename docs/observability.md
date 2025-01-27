# Observability

## OpenTelemetry

Container images:

- `otel/opentelemetry-collector`: [hub.docker.com](https://hub.docker.com/r/otel/opentelemetry-collector/tags)
- `otel/opentelemetry-collector-k8s`: [hub.docker.com](https://hub.docker.com/r/otel/opentelemetry-collector-k8s/tags)

### Init

Add Helm repository ([source](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)):

```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```

Create the namespace:

```bash
kubectl create ns observability
```

## OTLP receiver

/!\ Daemonset is not possible as no image available for Windows (maybe in the future with [issue #339](https://github.com/open-telemetry/opentelemetry-collector-releases/issues/339))

Create the configuration file (ref. [values.yaml](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml)):

```bash
cat <<EOF > otel_otlp_values.yaml
mode: deployment
replicaCount: 1
nodeSelector:
  kubernetes.io/os: linux
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
      metrics:
        exporters:
          - debug/detailed
        receivers:
          - otlp
          # - prometheus
      traces:
        exporters:
          - debug/normal
        receivers:
          - otlp
image:
  repository: otel/opentelemetry-collector
  # https://github.com/open-telemetry/opentelemetry-collector-releases/pkgs/container/opentelemetry-collector-releases%2Fopentelemetry-collector
  # repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector
  tag: "0.118.0"
command:
  name: otelcol
  # name: otelcontribcol
ports:
  jaeger-compact:
    enabled: false
  jaeger-thrift:
    enabled: false
  jaeger-grpc:
    enabled: false
  zipkin:
    enabled: false
resources:
  limits:
    cpu: 250m
    memory: 512Mi
EOF
```

Install the application with Helm:

```bash
helm upgrade --install otel-otlp open-telemetry/opentelemetry-collector -f otel_otlp_values.yaml --namespace observability
kubectl wait pods -n observability -l app.kubernetes.io/instance=otel-otlp --for condition=Ready
```

## Kubernetes node receivers

Ref. [Filelog Receiver](https://opentelemetry.io/docs/kubernetes/getting-started/#filelog-receiver)

/!\ Daemonset is not yet possible as no image available for Windows

Create the configuration file (ref. [values.yaml](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml)):

```bash
cat <<EOF > otel_k8snode_values.yaml
mode: deployment
replicaCount: 1
nodeSelector:
  kubernetes.io/os: linux
presets:
  kubernetesAttributes:
    enabled: true
  kubeletMetrics:
    enabled: true
  logsCollection:
    enabled: true
config:
  exporters:
    debug/detailed:
      verbosity: detailed
    debug/normal:
      verbosity: normal
  receivers:
    jaeger: null
    otlp: null
    prometheus: null
    zipkin: null
  service:
    pipelines:
      logs:
        exporters:
          - debug/normal
        receivers:
          - filelog
      metrics:
        exporters:
          - debug/normal
        receivers:
          - kubeletstats
      traces: null
image:
  repository: otel/opentelemetry-collector-k8s
  tag: "0.118.0"
command:
  name: otelcol-k8s
ports:
  jaeger-compact:
    enabled: false
  jaeger-thrift:
    enabled: false
  jaeger-grpc:
    enabled: false
  zipkin:
    enabled: false
resources:
  limits:
    cpu: 125m
    memory: 256Mi
EOF
```

Install the application with Helm:

```bash
helm upgrade --install otel-k8snode open-telemetry/opentelemetry-collector -f otel_k8snode_values.yaml --namespace observability
kubectl wait pods -n observability -l app.kubernetes.io/instance=otel-k8snode --for condition=Ready
```

## Kubernetes cluster receives

Ref. [Kubernetes Cluster Receiver](https://opentelemetry.io/docs/kubernetes/getting-started/#kubernetes-cluster-receiver)

/!\ Daemonset is not yet possible as no image available for Windows

Create the configuration file (ref. [values.yaml](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml)):

```bash
cat <<EOF > otel_k8scluster_values.yaml
mode: deployment
replicaCount: 1
nodeSelector:
  kubernetes.io/os: linux
presets:
  clusterMetrics:
    enabled: true
  kubernetesEvents:
    enabled: true
config:
  exporters:
    debug/detailed:
      verbosity: detailed
    debug/normal:
      verbosity: normal
  receivers:
    jaeger: null
    otlp: null
    prometheus: null
    zipkin: null
  service:
    pipelines:
      logs:
        exporters:
          - debug/normal
        receivers:
          - k8sobjects
      metrics:
        exporters:
          - debug/normal
        receivers:
          - k8s_cluster
      traces: null
image:
  repository: otel/opentelemetry-collector-k8s
  tag: "0.118.0"
command:
  name: otelcol-k8s
ports:
  jaeger-compact:
    enabled: false
  jaeger-thrift:
    enabled: false
  jaeger-grpc:
    enabled: false
  zipkin:
    enabled: false
resources:
  limits:
    cpu: 125m
    memory: 256Mi
EOF
```

Install the application with Helm:

```bash
helm upgrade --install otel-k8scluster open-telemetry/opentelemetry-collector -f otel_k8scluster_values.yaml --namespace observability
kubectl wait pods -n observability -l app.kubernetes.io/instance=otel-k8scluster --for condition=Ready
```

### Clean-up

```bash
helm uninstall otel-otlp -n observability
helm uninstall otel-k8snode -n observability
helm uninstall otel-k8scluster -n observability
kubectl delete ns observability
```
