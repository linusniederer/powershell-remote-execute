
Class RemoteExecute {

    # Application config
    [System.Object] $config
    [bool] $writeLog


    <#
     # Constructor
     #>
    RemoteExecute() {

        $this.parseConfig()
        
    }

    <#
     # Parse configuration file into PowerShell object
     #>
    [void] parseConfig() {

        # read configuration
        $this.config = Get-Content './config.json' | ConvertFrom-Json
        $this.writeLog = $this.config.application.writeLog;
    }


    <#
     # Log messages
     #
     # @param Message to log
     #>
     [void] log($message) {
        $timestamp = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        
        # define color filter
        if($message -like '*error*') { Write-Host -ForegroundColor 'Red' "$timestamp #> $message" }
        elseIf($message -like '*success*') { Write-Host -ForegroundColor 'Green' "$timestamp #> $message" }
        elseIf($message -like '*warning*') { Write-Host -ForegroundColor 'Yellow' "$timestamp #> $message" }
        else { Write-Host "$timestamp #> $message" }

        # write log if defined
        if($this.writeLog) {
            if (!(Test-Path "./log/RemoteExecute.log")) {
                New-Item -path "./log/RemoteExecute.log" -value "$timestamp #> $message" -Force
            } else {
                Add-Content -Path './log/RemoteExecute.log' -Value "$timestamp #> $message"
            }
        }
    }
}



$application = [RemoteExecute]::new()