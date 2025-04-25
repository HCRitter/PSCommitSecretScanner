function Get-RemoteCommits {
    [CmdletBinding()]
    param (
        $Repository
    )
    
    begin {
        $commits = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits"
    }
    
    process {
        $ReturnObject = $commits | Select-Object| ForEach-Object {
            [PSCustomObject]@{
                Sha     = $_.sha
                Author  = $_.commit.author.name
                Date    = $_.commit.author.date
                Message = $_.commit.message
                FileChanges = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/commits/$($_.sha)" | Select-Object -ExpandProperty files | Select-Object filename, status, additions, deletions,Raw_Url, @{name='IsPowerShell'; expression={if($_.filename -match '\.ps(1|m1|d1)$'){
                        return $true
                    } else {
                        return $false
                    }}},@{name='Secrets';Expression={$null}},@{name='Code';Expression={$null}}
            } 
            
        }

        $ReturnObject.ForEach({
            $_.PStypeNames.clear()
            $_.PStypeNames.Add("PSCommitScannerObject")
        })
    }
    
    end {
        return $ReturnObject
    }
}