# .NET samples

## Applications

### Razor Web Application

An ASP.NET Core Razor Pages application on .NET 10, in a Nano Server image.

The code builds and is tested on any operating system:

```bash
dotnet test --solution Devpro.SampleDotnetApps.slnx
```

The image is a Windows image, built and checked from the root of the repository:

```bash
scripts/test_images.sh winsamplenet10razorwebapp
```

The application listens on port 8080, and runs as `ContainerUser`, without administrator rights.
