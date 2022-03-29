# powershell-remote-execute








## Instruction Types

### Application
```json
{
    "type": "application",
    "command": "",
    "path": "C:\\Temp\\test.exe",
    "params": ""
}
```


### Command
```json
{
    "type": "command",
    "command": "[PowerShell command to execute]",
    "path": "[Path if command requires path]",
    "params": "[Params if command requires params]"
}
```

```json
{
    "type": "command",
    "command": "New-Item",
    "path": "C:\\Users\\Public\\Desktop\\File.txt",
    "params": "-FileType File -Force"
}
```