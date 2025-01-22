# Cluster validation

## IIS

```yaml
# This yaml can be deployed for Windows 2019. Change the image for 2022.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iis-servercore-1809
  labels:
    app: 1809-iis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: 1809-iis
  template:
    metadata:
      labels:
        app: 1809-iis
    spec:
      nodeSelector:
        kubernetes.io/os: windows
      containers:
      - name: iis-servercore-1809
        image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
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
  name: iis-servercore-1809-svc
  labels:
    app: 1809-iis
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    app: 1809-iis
```
