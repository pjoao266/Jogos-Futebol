@echo off
set /p arg="Audio? 0: Nao, 1:Sim ? "
"C:/Program Files/R/R-4.0.3/bin/x64/R.exe" -e args=%arg%;source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\roda_busca.R')
pause