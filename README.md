# powershell-remote-execute








## Instruction Types

### Application
'''json
{
    "type": "application",
    "command": "",
    "path": "C:\\Temp\\test.exe",
    "params": ""
}
'''


### Command
'''json
{
    "type": "command",
    "command": "New-Item",
    "path": "C:\\Temp\\test456.txt",
    "params": "-ItemType File -Force"
}
'''