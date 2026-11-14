# .NET 4.8 samples

## Applications

### MVC Web Application

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/devprofr/winsamplenet48mvcwebapp?label=Docker)](https://hub.docker.com/r/devprofr/winsamplenet48mvcwebapp)

An ASP.NET MVC 5 application on .NET Framework 4.8, served by IIS on port 80 in a Windows Server Core image.

### Windows Service

[![Docker Image Version](https://img.shields.io/docker/v/devprofr/winsamplenet48svc?logo=docker&label=devprofr/winsamplenet48svc)](https://hub.docker.com/r/devprofr/winsamplenet48svc)

A Windows service on .NET Framework 4.8, in a Windows Server Core image.
A service only runs under the Service Control Manager,
so the image registers it to run as `NT AUTHORITY\LocalService`, and the container lives as long as the service runs.

## Checks

The code is built and tested with MSBuild and VSTest from Visual Studio, as the CI does on Windows.
The images are built and checked from the root of the repository:

```bash
scripts/test_images.sh winsamplenet48mvcwebapp winsamplenet48svc
```
