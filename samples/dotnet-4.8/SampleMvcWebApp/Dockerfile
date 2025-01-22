ARG DOTNET_VERSION=4.8-windowsservercore-ltsc2022

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
