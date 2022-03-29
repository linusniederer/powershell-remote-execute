
Class Server {

    [string] $name
    [string] $fdqn
    [ipaddress] $ipaddress      = $null
    [PSCredential] $credentials = $null
    [bool] $writeLog            = $true

    <#
     # Constructor 
     #
     # @param Server Name
     #>
    Server($name, $fqdn) {
        $this.name = $name
    }







}
