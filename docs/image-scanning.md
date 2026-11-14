# Image scanning

A Windows image is harder to scan than a Linux one.
No scanner finds the Windows release and its updates (KB) the way it finds the packages of a Linux distribution,
so what a scanner reports depends on the files it recognizes in the image.

## In the pipeline

The CI builds every image on Windows Server 2025 without pushing it, then scans it with [Grype](https://github.com/anchore/grype).

- Every finding is printed in the log of the job.
- A critical vulnerability fails the job.
- A high one does not, since today all of them are in the Windows base image, which only a new base image from Microsoft fixes.

The NuGet packages are also checked at restore, before any image is built.
A package with a known high or critical vulnerability fails the restore,
through `Directory.Build.props` for the .NET sample and `Directory.Solution.props` for the .NET Framework one,
where a `packages.config` restore runs for the solution.

The Windows layer is kept up to date by building on the latest base image, which Microsoft updates every month.

## Scanners compared

Results of November 2026 on the images of this repository, with Trivy 0.76.2 and Grype 0.121.3.

Image              | Trivy                                                          | Grype
-------------------|----------------------------------------------------------------|---------------------------------------------------------------
.NET 10 app        | .NET runtime, ASP.NET Core and the app, from their `deps.json` | the same, and Windows binaries such as `winsqlite3.dll`
.NET Framework app | nothing, neither operating system nor package                  | every .NET assembly with its version, and the Windows binaries

Trivy reads a .NET Framework application only from its sources, through `packages.config`, which a published application no longer has.
Grype reads the version written in each assembly and binary, so it needs nothing more than the image.

## Earlier attempts

The first image scans of this repository were tried in January 2025, on the .NET Framework 4.8 images.

Tool                   | Result
-----------------------|------------------------------------------------------------------------------------
Snyk                   | "Operating system is not supported"
Deepfence ThreatMapper | needs a running console and an account, the scanner alone fails with a 401 response
Trivy                  | did not scan the .NET Framework code
Grype                  | the only one to analyze the .NET Framework application

## Local scan

An image built on the Windows engine is exported, then scanned from WSL or any Linux machine.

```bash
docker.exe --context win save --output image.tar winsamplenet48mvcwebapp:local
grype docker-archive:image.tar
```
