function Start-RemoteRepoScan {
    [CmdletBinding()]
    param (
        [string]$RepoUrl,
        #[string]$Branch = "main",
        #[string]$OutputPath = "C:\Temp\Scan-RemoteRepo",
        #[string]$OutputFile = "Scan-RemoteRepo.json",
        [ValidateSet("Github")]
        [string]$Provider = "Github",
        [ValidateSet("Commits","Live")]
        [string]$ScanType = "Commits",
        [ValidateSet("All","SecretsOnly")]
        [string]$OutputType = "All",
        [int]$CommitInDays = 0
    )
    
    begin {
        If($ScanType -eq "Commits"){
            $Commits = [System.Collections.Generic.List[object]]::new()
            $Commits.AddRange($(Get-RemoteCommits -Repository $RepoUrl))
            if($CommitInDays -gt 0){
                Write-Verbose "Filtering commits to last $CommitInDays days" 
                $Commits = $Commits | Where-Object { $_.Date -ge (Get-Date).AddDays(-$CommitInDays) }
            }
        }
        if($ScanType -eq "Live"){
            Write-Warning "Live scan is not implemented yet. Please use Commits scan."
            return
        }
        $PatternConfig = Get-PatternConfig 
    }
    
    process {
        foreach($Commit in $Commits){
            foreach($FileChange in @($Commit.FileChanges)){
                $Content = Invoke-RestMethod -Uri $FileChange.Raw_Url -Method Get 
                $FileChange.Code = $Content
                $Lines = $Content -split "`n"
                $Hits = for ($i = 0; $i -lt $lines.Length; $i++) {
                    $Line = $Lines[$i]
                    foreach($PatternName in $PatternConfig.Values.Keys){
                        if($Line -match $PatternConfig["regexes"]."$PatternName"){
                            Write-Host "Found $PatternName in $($FileChange.filename) on line $($i + 1)" -ForegroundColor Red
                            Write-Host "In Commit: $($Commit.Sha) by $($Commit.Author) on $($Commit.Date)" -ForegroundColor Yellow
                            [PSCustomObject]@{
                                PatternName = $PatternName
                                Pattern = $Pattern = $PatternConfig["regexes"]."$PatternName"
                                LineNumber = $i +1
                                Line = $Line
                                Secret = $($([regex]::Match($Line, $pattern);$Match.Value)).Value
                            }
                        }
                    }
                }
                $FileChange.Secrets = $Hits
            }
            

        }
    }
    
    end {
        if($OutputType -eq "All"){
            return $Commits
        } elseif($OutputType -eq "SecretsOnly"){
            return ($Commits |where-Object {$_.FileChanges | where-Object {$_.Secrets -ne $null}}) | Select-Object Sha,Author,Date,Message,@{name="Secrets";expression={$_.FileChanges.Secrets.PatternName}} 
        }
        
    }
}