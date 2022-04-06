# PowerShell Tool to create SecureString from Password
#
# @author:      https://github.com/linusniederer
# @created:     06.04.2022
#
$credentials = Get-Credential
$credentials.Password | ConvertFrom-SecureString | Out-File .\secureString.cred