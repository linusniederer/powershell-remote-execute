# PowerShell Remote Execution Tool 
#
# @author:      https://github.com/linusniederer
# @created:     29.03.2022
#
# @changelog:   https://github.com/linusniederer/powershell-remote-execute#changelog
# @current:     https://github.com/linusniederer/powershell-remote-execute#version-101---04-feb-2022
#

Param( $action )
if( $action -ne $null ) { $action = $action.ToLower() }


Class RemoteExecute {

    # Application config
    [System.Object] $config
    [bool] $writeLog
    
    # Server Array
    [array] $servers = @()
    
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
        
        if($this.config -ne $null) {
            # read application configuration
            $this.writeLog = $this.config.application.writeLog;

            # read server configuration
            foreach($server in $this.config.servers) {
                $state = $this.isAlive($server.fqdn, $server.ip)            
                $this.addServer( $server.name, $server.fqdn, $server.ip, $state )
            }
        
        } else {
            $this.log("ERROR: Can't read configuration file! File must have name [config.json] and has to be stored in root!")
        }
        
    }

    <#
     # Method to add new server object
     #
     # @param Name
     # @param Full Qualified Domain Name
     # @param IP Address
     #>
    hidden [void] addServer($name, $fqdn, $ipaddress, $state) {

        $server = New-Object -TypeName psobject

        $server | Add-Member -MemberType NoteProperty -Name Name -Value $name
        $server | Add-Member -MemberType NoteProperty -Name FQDN -Value $fqdn
        $server | Add-Member -MemberType NoteProperty -Name IPAddress -Value $ipaddress
        $server | Add-Member -MemberType NoteProperty -Name Status -Value $state
        
        $this.servers += $server
    }

    <#
     # Method to get connectivity of server
     #
     # @param Full Qualified Domain Name
     # @return Online || Offline
     #>
    hidden [string] isAlive($fqdn, $ipaddress) {

        if( $fqdn -ne $null -AND (Test-Connection -ComputerName $fqdn -Quiet -Count 1 )) {
            $this.log("SUCCESS: Server [$fqdn] is online, commands will be sent over FQDN!")
            return "online"
        } 

        if( $ipaddress -ne $null -AND (Test-Connection -ComputerName $ipaddress -Quiet -Count 1 )) {
            $this.log("SUCCESS: Server [$ipaddress] is online, commands will be sent over ipv4!")
            return "online"
        }

        $this.log("WARNING: Server [$fqdn] is offline, no commands will be executed!")
        return "offline"
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


# Call to static property
$application = [RemoteExecute]::new()

switch($action) {
    'INFO'     { Write-Host $application.servers }
}

$application.servers
