# Stress tests

## Init

Create namespace:

```yaml
kubectl create ns stress-test
```

## PowerShell Script

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: windows-memory-test
  namespace: stress-test
spec:
  nodeSelector:
    kubernetes.io/os: windows
  containers:
    - name: memory-consumer
      image: mcr.microsoft.com/powershell:windowsservercore-ltsc2022
      command: ["powershell.exe"]
      args:
        - -Command
        - |
          \$memoryList = New-Object System.Collections.Generic.List[Object]

          \$totalMemory = 0
          \$chunkSizeMB = 10

          while (\$true) {
              try {
                  \$largeObject = [byte[]]::new(\$chunkSizeMB * 1MB)
                  
                  \$memoryList.Add(\$largeObject)
                  
                  \$totalMemory += \$chunkSizeMB
                  
                  Write-Output "Memory used: \$totalMemory MB"
                  
                  Start-Sleep -Milliseconds 50
              }
              catch {
                  Write-Output "Caught an exception: \$_"
                  break
              }
          }

          Write-Output "Script ended or hit an error."
      resources:
        requests:
          memory: "128Mi"
        limits:
          memory: "512Mi"
  restartPolicy: Always
EOF
```

Monitor with:

```bash
kubectl top pod windows-memory-test -n stress-test
```

## Clean up

```bash
kubectl delete pod windows-memory-test -n stress-test --grace-period=0 --force
kubectl delete ns stress-test
```
