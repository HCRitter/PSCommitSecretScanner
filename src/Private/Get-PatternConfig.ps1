function Get-PatternConfig {
    [CmdletBinding()]
    param (
        $ConfigPath = "$PSScriptRoot\Patterns.json"
    )
    
    begin {

    }
    
    process {
        try {
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $Config = Get-Content $ConfigPath -ErrorAction Stop | ConvertFrom-Json -AsHashtable
            } 
            else {
                $Config = Get-Content $ConfigPath -ErrorAction Stop -Raw | ConvertFrom-Json | ConvertToHashtable
            }
        }
        catch {
            Throw "Failed to get config. $_"
        }
    }
    
    end {
        return $Config
    }
}