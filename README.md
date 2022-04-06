# PowerShell Remote Execution

## Instruction Types
### Command
```json
{
    "type": "command",
    "command": "[PowerShell command to execute]",
    "path": "[Path if command requires path]",
    "params": "[Params if command requires params]"
}
```

### Application
```json
{
    "type": "application",
    "command": "",
    "path": "[Path to executable]",
    "params": "[Params for executable]"
}
```
