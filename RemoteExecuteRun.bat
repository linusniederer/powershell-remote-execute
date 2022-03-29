@echo off
REM ***************************************************
REM *** 	 Execute instructions on servers        ***
REM ***************************************************

TITLE Execute instructions on servers
MODE con:cols=120 lines=40

REM *** Execute instructions on servers
powershell -ExecutionPolicy Bypass -File "%~dp0RemoteExecute.ps1" "RUN"