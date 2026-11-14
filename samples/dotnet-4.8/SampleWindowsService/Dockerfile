ARG DOTNET_VERSION=4.8.1-windowsservercore-ltsc2025

# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/sdk/tags
FROM mcr.microsoft.com/dotnet/framework/sdk:${DOTNET_VERSION} AS build
WORKDIR /src

COPY . .
RUN nuget restore
RUN msbuild SampleWindowsService/SampleWindowsService.csproj /p:Configuration=Release /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/runtime/tags
FROM mcr.microsoft.com/dotnet/framework/runtime:${DOTNET_VERSION} AS runtime
WORKDIR /app

COPY --from=build /src/SampleWindowsService/bin/Release/ .

# A Windows service refuses to run from a command line, so it is registered with the Service Control Manager of the image.
RUN sc.exe create SampleWindowsService binPath= "C:\app\SampleWindowsService.exe" start= demand

# The container lives as long as the service, as nothing else keeps it running.
ENTRYPOINT ["powershell", "-NoProfile", "-Command", "Start-Service SampleWindowsService; Get-Service SampleWindowsService; while ((Get-Service SampleWindowsService).Status -eq 'Running') { Start-Sleep -Seconds 5 }; Get-Service SampleWindowsService; exit 1"]
