@{
    RootModule = 'PSCommitSecretScanner.psm1'
    ModuleVersion = '0.0.1'
    GUID = '658a9944-95a1-486e-bb96-63f17f590a41'
    Author = 'Christian Ritter'
    CompanyName = 'HCRitter'
    Copyright = 'HCRitter 2024'
    Description = 'This Module scans commits in a repo for secrets'
    PowerShellVersion = '5.1'
    CLRVersion = '4.0.30319.42000'

    FunctionsToExport = @('Start-RemoteRepoScan')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}