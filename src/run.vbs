Set oShell = CreateObject ("Wscript.Shell") 
Dim strArgs
strArgs = "cmd /c roda_processo.bat"
oShell.Run strArgs, 0, false