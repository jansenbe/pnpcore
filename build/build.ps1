#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$versionIncrement = Get-Content ./build/version.debug.increment -Raw
$versionIncrement = $versionIncrement -as [int]
$versionIncrement = $versionIncrement + 1

$version = Get-Content ./build/version.debug -Raw
$blazorVersion = Get-Content ./build/version.blazor -Raw

$version = $version.Replace("{incremental}", $versionIncrement)
$blazorVersion = $blazorVersion.Replace("{incremental}", $versionIncrement)

Write-Host "Building PnP.Core .Net Standard 2.0 version $version"
dotnet build ./src/sdk/PnP.Core/PnP.Core.csproj --no-incremental /p:Version=$version

Write-Host "Building PnP.Core.Auth .Net Standard 2.0 version $version"
dotnet build ./src/sdk/PnP.Core.Auth/PnP.Core.Auth.csproj --no-incremental /p:Version=$version

Write-Host "Building PnP.Core Blazor .Net Standard 2.0 version $version"
dotnet build ./src/sdk/PnP.Core/PnP.Core.csproj --no-incremental --configuration Blazor /p:Version=$blazorVersion

Write-Host "Packinging PnP.Core .Net Standard 2.0 version $version"
dotnet pack ./src/sdk/PnP.Core/PnP.Core.csproj --no-build /p:PackageVersion=$version

Write-Host "Packinging PnP.Core.Auth .Net Standard 2.0 version $version"
dotnet pack ./src/sdk/PnP.Core.Auth/PnP.Core.Auth.csproj --no-build /p:PackageVersion=$version

Write-Host "Packinging PnP.Core Blazor .Net Standard 2.0 version $version"
dotnet pack ./src/sdk/PnP.Core/PnP.Core.csproj --no-build --configuration Blazor /p:PackageVersion=$blazorVersion

Write-Host "Publishing to nuget"
$nupkg = $("./src/sdk/PnP.Core/bin/Debug/PnP.Core.$version.nupkg")
$authNupkg = $("./src/sdk/PnP.Core.Auth/bin/Debug/PnP.Core.Auth.$version.nupkg")
$blazorNupkg = $("./src/sdk/PnP.Core/bin/Blazor/PnP.Core.$blazorVersion.nupkg")
$apiKey = $("$env:NUGET_API_KEY")

#Write-Host "API Key starts with:" $apiKey.Substring(0,10)

dotnet nuget push $nupkg --api-key $apiKey --source https://api.nuget.org/v3/index.json
dotnet nuget push $authNupkg --api-key $apiKey --source https://api.nuget.org/v3/index.json
dotnet nuget push $blazorNupkg --api-key $apiKey --source https://api.nuget.org/v3/index.json

Write-Host "Writing $version to git"
Set-Content -Path ./build/version.debug.increment -Value $versionIncrement