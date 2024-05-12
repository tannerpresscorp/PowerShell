# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
Import-Module "$PSScriptRoot\dockerInstall.psm1"

# Install using Wix Zip because the MSI requires an older version of dotnet
# which was large and unstable in docker
function Install-Wix
{
    param($arm64 = $false)

    $targetRoot = $arm64 ? "${env:ProgramFiles(x86)}\Arm Support WiX Toolset xcopy" : "${env:ProgramFiles(x86)}\WiX Toolset xcopy"
    # cleanup previous install
    if(Test-Path $targetRoot) {
        Remove-Item $targetRoot -Recurse -Force
    }
    $binPath = Join-Path -Path $targetRoot -ChildPath 'bin'
    Register-PSRepository -Name 'dotnet-eng' -SourceLocation "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-eng/nuget/v3/index.json"
    # keep version in sync with Microsoft.PowerShell.Packaging.csproj
    Save-Module -name Microsoft.Signed.Wix -RequiredVersion '3.14.1-8722.20240403.1' -path "$binPath/"
    $docExpandPath = Join-Path -Path $binPath -ChildPath 'doc'
    $sdkExpandPath = Join-Path -Path $binPath -ChildPath 'sdk'
    $docTargetPath = Join-Path -Path $targetRoot -ChildPath 'doc'
    $sdkTargetPath = Join-Path -Path $targetRoot -ChildPath 'sdk'
    Write-Verbose "Fixing folder structure ..." -Verbose
    Move-Item -Path $docExpandPath -Destination $docTargetPath
    Move-Item -Path $sdkExpandPath -Destination $sdkTargetPath
    Append-Path -path $binPath
    Write-Verbose "Done installing WIX!"
}
