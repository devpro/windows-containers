# Built from samples/dotnet-10.0, whose .dockerignore leaves out bin, obj and local settings.
# Nano Server is the smallest Windows base, and enough for an app that needs nothing else from Windows.
# https://mcr.microsoft.com/artifact/mar/dotnet/aspnet/tags
ARG DOTNET_VERSION=10.0-nanoserver-ltsc2025

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
WORKDIR /src

# The restore layer is kept in cache as long as the project file does not change.
COPY ["src/SampleRazorWebApp/SampleRazorWebApp.csproj", "src/SampleRazorWebApp/"]
RUN dotnet restore src/SampleRazorWebApp/SampleRazorWebApp.csproj

COPY src/ src/
RUN dotnet publish src/SampleRazorWebApp/SampleRazorWebApp.csproj --no-restore --configuration Release --output /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS final
WORKDIR /app
EXPOSE 8080

COPY --from=build /app/publish .

# The base image already runs as this account without administrator rights, which is stated so that no later change drops it unnoticed.
USER ContainerUser

# An orchestrator restarts a container whose application stops answering, which a running process alone does not show.
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD curl.exe --fail --silent --output NUL http://localhost:8080/

ENTRYPOINT ["dotnet", "SampleRazorWebApp.dll"]
