ARG DOTNET_VERSION=4.8.1-windowsservercore-ltsc2025

# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/sdk/tags
FROM mcr.microsoft.com/dotnet/framework/sdk:${DOTNET_VERSION} AS build
WORKDIR /src

COPY . .
RUN nuget restore
RUN msbuild SampleMvcWebApp/SampleMvcWebApp.csproj /p:Configuration=Release /p:DeployOnBuild=true /p:PublishUrl="c:\publish" /p:WebPublishMethod=FileSystem /p:DeployDefaultTarget=WebPublish

# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/runtime/tags
FROM mcr.microsoft.com/dotnet/framework/aspnet:${DOTNET_VERSION} AS runtime
WORKDIR /inetpub/wwwroot

COPY --from=build /publish ./

# The entrypoint of the image starts the IIS service, which needs an administrator, and the site runs under its application pool identity.
USER ContainerAdministrator

# An orchestrator restarts a container whose site stops answering, which a running IIS alone does not show.
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl.exe --fail --silent --output NUL http://localhost/
