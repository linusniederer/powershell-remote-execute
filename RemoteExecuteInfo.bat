@echo off
REM ***************************************************
REM *** 	        Get Server Info                 ***
REM ***************************************************

TITLE "Server Information"
MODE con:cols=120 lines=40

REM *** Read all Server from configuration
powershell -ExecutionPolicy Bypass -File "%~dp0RemoteExecute.ps1" "INFO"

pause -n