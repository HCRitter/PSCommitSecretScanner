#Load all files into memory

$script:ModulePath = $PSScriptRoot

Get-ChildItem -Path $script:ModulePath -Recurse -Include *.ps1 | ForEach-Object {
    . $_.FullName
}	


Export-ModuleMember -Function Start-RemoteRepoScan

# Updating the View

Update-FormatData -PrependPath $script:ModulePath\PSCommitScannerView.format.ps1xml