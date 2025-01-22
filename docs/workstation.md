# Workstation

## Local development

### Requirements

* SDKs: .NET 4.8
* IDE: Visual Studio 2022 Community (or others)
* Container runtime: Docker CE
  * Download and extract latest version of docker from [download.docker.com](https://download.docker.com/win/static/stable/x86_64/)
  * Open a terminal as an Administrator and start Docker daemon

  ```dos
  C:\Programs\docker-20.10.19\dockerd.exe -H npipe:////./pipe/docker_windows
  ```

  * Open a terminal as an Administrator and create Docker context

  ```dos
  C:\Programs\docker-20.10.19\docker.exe context create win --docker host=npipe:////./pipe/docker_windows
  ```

  * Optional: Set Docker context (make sure DOCKER_HOST environment variable is not set)

  ```dos
  C:\Programs\docker-20.10.19\docker.exe context use win
  ```

### Samples directory

Switch to the code repository:

```dos
cd samples\dotnet-4.8
```

### Build from the command line

Open a terminal with msbuild (for example Developer Command Prompt for VS 2022) and run:

```dos
msbuild
```

### Build and run in a container

Build a container image:

```dos
C:\Programs\docker-20.10.19\docker.exe -c win build . -t devprofr/winsamplenet48mvcwebapp -f SampleMvcWebApp/Dockerfile --build-arg DOTNET_VERSION=4.8 --no-cache
```

Start a container:

```dos
C:\Programs\docker-20.10.19\docker.exe -c win run -it --rm -p 9002:80 devprofr/winsamplenet48mvcwebapp
```

Open the local instance [localhost:9002](http://localhost:9002/).
