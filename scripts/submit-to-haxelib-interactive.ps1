#Requires -Version 7.0

using namespace System.IO

[string]$projectName = "tostring"
[string]$projectRoot = $PSScriptRoot | Split-Path -Parent
[string]$now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd'T'HH-mm-ss'Z'")
[string]$zipPath = Join-Path $projectRoot "$($projectName)_$($now).zip"

[FileInfo]$archiveFile = @(
    "haxelib.json", "*.hxml",
    "src",
    "LICENSE.txt",
    "README.md"
)
| ForEach-Object -Process { Join-Path $projectRoot $_ }
| Get-Item
| Compress-Archive -DestinationPath $zipPath -CompressionLevel Optimal -PassThru

Write-Output "Created .zip file, size is $($archiveFile.Length) bytes"

haxelib submit $zipPath
