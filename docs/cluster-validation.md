# Cluster validation

## IIS

Kubernetes runs Windows containers with process isolation only,
so the image is built for the Windows version of the nodes: `ltsc2022` for Windows Server 2022, `ltsc2025` for Windows Server 2025.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iis-servercore
  labels:
    app: iis-servercore
spec:
  replicas: 1
  selector:
    matchLabels:
      app: iis-servercore
  template:
    metadata:
      labels:
        app: iis-servercore
    spec:
      nodeSelector:
        kubernetes.io/os: windows
      containers:
      - name: iis-servercore
        image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2025
        ports:
        - containerPort: 80
        env:
          - name: RKE2_COREDNS_RKE2_COREDNS_SERVICE_HOST
            value: "10.43.0.10"
          - name: RKE2_COREDNS_RKE2_COREDNS_PORT_53_TCP
            value: "tcp://10.43.0.10:53"
          - name: RKE2_COREDNS_RKE2_COREDNS_PORT_53_TCP_ADDR
            value: "10.43.0.10"
          - name: RKE2_COREDNS_RKE2_COREDNS_PORT_53_TCP_PORT
            value: "53"
          - name: RKE2_COREDNS_RKE2_COREDNS_SERVICE_PORT
            value: "53"
          - name: RKE2_COREDNS_RKE2_COREDNS_SERVICE_PORT_TCP_53
            value: "53"
          - name: RKE2_COREDNS_RKE2_COREDNS_PORT_53_TCP_PROTO
            value: "tcp"
---
apiVersion: v1
kind: Service
metadata:
  name: iis-servercore-svc
  labels:
    app: iis-servercore
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    app: iis-servercore
```
