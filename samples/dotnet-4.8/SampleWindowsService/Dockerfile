# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/sdk/tags
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 AS build
WORKDIR /src

COPY . .
RUN nuget restore
RUN msbuild Devpro.SampleWindowsApps.sln /p:Configuration=Release /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

# https://mcr.microsoft.com/en-us/artifact/mar/dotnet/framework/runtime/tags
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8 AS runtime
WORKDIR /app

COPY --from=build /src/SampleWindowsService/bin/Release/ .

ENTRYPOINT ["SampleWindowsService.exe"]
