# PowerShell Remote Execution Tool 
#
# @author:      https://github.com/linusniederer
# @created:     29.03.2022
#
# @changelog:   https://github.com/linusniederer/powershell-remote-execute#changelog
# @current:     https://github.com/linusniederer/powershell-remote-execute#version-101---04-feb-2022
#

Param( $action )
if( $null -ne $action ) { $action = $action.ToLower() }

Class RemoteExecute {

    # Application config
    [System.Object] $config
    [bool] $writeLog
    [bool] $debug

    [PSCredential] $cred = $null

    # Server and command piplines 
    [array] $servers = @()
    [array] $instructions = @()
    
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
        
        if($null -ne $this.config) {
            # read application configuration
            $this.writeLog  = $this.config.application.writeLog;
            $this.debug     = $this.config.application.debug;

            # get credentials
            $username = "$($this.config.credentials.domain)\$($this.config.credentials.username)"
            $securePassword = $this.config.credentials.password | ConvertTo-SecureString
            $this.cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $securePassword)

            # read server configuration
            foreach($server in $this.config.servers) {
                $state = $this.isAlive($server.fqdn, $server.ip)            
                $this.addServer( $server.name, $server.fqdn, $server.ip, $state )
            }

            # read command configuraton
            foreach($instruction in $this.config.instructions) {
                $this.addInstruction( $instruction.type, $instruction.command, $instruction.path, $instruction.params)
            }
        
        } else {
            $this.log("ERROR: Can't read configuration file! File must have name [config.json] and has to be stored in root!")
        }
        
    }

    [void] executeCommands() {

        # Loop through servers and execute all instrutions
        foreach($server in $this.servers) {

            if($server.Status -eq "online") {

                # create new server session
                $session = New-PSSession -ComputerName $server.FQDN -Credential $this.cred
                $this.log("Create new Session for Server [$($server.Name)]")

                foreach($instruction in $this.instructions) {

                    $this.log("Send instruction to Server [$($server.Name)]
                        type:       [$($instruction.Type)]
                        command:    [$($instruction.Command)]
                        path:       [$($instruction.Path)]
                        params:     [$($instruction.Params)] ")

                    $parameters = @{
                        Session = $session
                        ArgumentList = $instruction.Type, $instruction.Command, $instruction.Path, $instruction.Params
                        ScriptBlock = {
                            param($type, $command, $path, $params) 

                            if($type -eq "command") {
                                $expression = "$command $path $params"
                            }

                            if($type -eq "application") {
                                $application = "$path '$params'"
                                $expression = "Start-Process $path -ArgumentList '$params'"
                            }
                            
                            return Invoke-Expression $expression
                        } 
                    }

                    $result = Invoke-Command @parameters
                }
            }
        }

        $this.log("All instructions were sent to all servers!")
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
     # Method to add new server object
     #
     # @param Full Qualified Domain Name
     # @param IP Address
     #>
     hidden [void] addInstruction($type, $command, $path, $params) {

        $instruction = New-Object -TypeName psobject

        $instruction | Add-Member -MemberType NoteProperty -Name Type -Value $type
        $instruction | Add-Member -MemberType NoteProperty -Name Command -Value $command
        $instruction | Add-Member -MemberType NoteProperty -Name Path -Value $path
        $instruction | Add-Member -MemberType NoteProperty -Name Params -Value $params
        
        $this.instructions += $instruction
    }

    <#
     # Method to get connectivity of server
     #
     # @param Full Qualified Domain Name
     # @return Online || Offline
     #>
    hidden [string] isAlive($fqdn, $ipaddress) {

        if( $null -ne $fqdn -AND (Test-Connection -ComputerName $fqdn -Quiet -Count 1 )) {
            $this.log("SUCCESS: Server [$fqdn] is online, commands will be sent over FQDN!")
            return "online"
        } 

        if( $null -ne $ipaddress -AND (Test-Connection -ComputerName $ipaddress -Quiet -Count 1 )) {
            $this.log("SUCCESS: Server [$ipaddress] is online, commands will be sent over ipv4!")
            $this.log("WARNONG: Server [$ipaddress] is not reachable over FQDN, this will cause an error while sending instructions!")
            return "online"
        }

        $this.log("ERROR: Server [$fqdn] is offline, no commands will be executed!")
        return "offline"
    }

    <#
     # Log messages
     #
     # @param Message to log
     #>
     [void] log($message) {
        $timestamp = Get-Date -Format "dd.MM.yyyy HH:mm:ss"

        if($this.debug) {    
            # define color filter
            if($message -like '*error*') { Write-Host -ForegroundColor 'Red' "$timestamp #> $message" }
            elseIf($message -like '*success*') { Write-Host -ForegroundColor 'Green' "$timestamp #> $message" }
            elseIf($message -like '*warning*') { Write-Host -ForegroundColor 'Yellow' "$timestamp #> $message" }
            else { Write-Host "$timestamp #> $message" }
        }

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

$application.executeCommands()

switch($action) {
    'INFO' { 
        Write-Host "Found the following servers in the configuration:"
        $application.servers | Format-Table

        Write-Host "Found the following instructions in the configuration:"
        $application.instructions | Format-Table
     }
     'RUN' {
        $application.executeCommands()
     }
}