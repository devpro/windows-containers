# 8.0-nanoserver-1809
ARG DOTNET_VERSION=8.0-nanoserver-ltsc2022

FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0-nanoserver-1809 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SampleRazorWebApp/SampleRazorWebApp.csproj", "SampleRazorWebApp/"]
RUN dotnet restore "./SampleRazorWebApp/SampleRazorWebApp.csproj"
COPY . .
WORKDIR "/src/SampleRazorWebApp"
RUN dotnet build "./SampleRazorWebApp.csproj" -c %BUILD_CONFIGURATION% -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./SampleRazorWebApp.csproj" -c %BUILD_CONFIGURATION% -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleRazorWebApp.dll"]
