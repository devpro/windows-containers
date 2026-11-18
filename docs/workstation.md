# Workstation

## Local development

### Requirements

* Visual Studio 2026 Community with ASP.NET and .NET SDK 4.8
* IDE: Rider (recommended and free for personal projects), Visual Studio 2026 Community (free), or Visual Studio Code (free and open source)
* Container runtime: Docker CE
  * Download and extract latest version of docker from [download.docker.com](https://download.docker.com/win/static/stable/x86_64/)
  * Copy docker.exe and dockerd.exe in a directory included in PATH
  * Open a terminal as an Administrator and start Docker daemon for a quick check

  ```dos
  dockerd.exe -H npipe:////./pipe/docker_windows
  ```

  * Stop the previous command (Ctrl+C) and register the service

  ```dos
  dockerd --register-service -H npipe:////./pipe/docker_windows
  ```

  * Create Docker user group add the user to it

  ```dos
  net localgroup docker-users /add
  net localgroup docker-users %USERNAME% /add
  mkdir C:\ProgramData\docker\config
  echo {"group": "docker-users"} > C:\ProgramData\docker\config\daemon.json
  ```

  * Start the service

  ```dos
  net start docker
  ```

  * Create Docker context

  ```dos
  docker.exe context create win --docker host=npipe:////./pipe/docker_windows
  ```

  * Optional: Set Docker context (make sure DOCKER_HOST environment variable is not set)

  ```dos
  docker.exe context use win
  ```

  * From a normal terminal (not admin), do a quick check

  ```dos
  docker.exe -c win ps
  ```

  * Login Dockerhub (will write `%USERPROFILE%\.docker\config.json`)

  ```dos
  docker.exe -c win login
  ```

  * Optional: run hello world image

  ```dos
  docker.exe -c win run --rm hello-world
  ```

  * Pull images

  ```dos
  docker.exe --context win pull mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2025
  docker.exe --context win pull mcr.microsoft.com/dotnet/framework/aspnet:4.8.1-windowsservercore-ltsc2025
  docker.exe --context win pull mcr.microsoft.com/dotnet/framework/runtime:4.8.1-windowsservercore-ltsc2025
  docker.exe --context win pull mcr.microsoft.com/dotnet/sdk:10.0-nanoserver-ltsc2025
  docker.exe --context win pull mcr.microsoft.com/dotnet/aspnet:10.0-nanoserver-ltsc2025
  docker.exe --context win pull mcr.microsoft.com/windows/nanoserver:ltsc2025
  ```
  
### Samples directory

Switch to the code repository:

```dos
cd samples\dotnet-4.8
```

### Build from the command line

Open a terminal with msbuild (for example Developer Command Prompt for VS 2026) and run:

```dos
msbuild
```

### Build and run in a container

Build a container image:

```dos
docker.exe -c win build . -t devprofr/winsamplenet48mvcwebapp -f SampleMvcWebApp/Dockerfile --no-cache
```

Start a container:

```dos
docker.exe -c win run -it --rm -p 9002:80 devprofr/winsamplenet48mvcwebapp
```

Open the local instance [localhost:9002](http://localhost:9002/).

### Testing

Run `scripts/test_images.sh`.
