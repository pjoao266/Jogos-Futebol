roda_busca = function(rd){
  link = 'https://www.uol.com.br/esporte/futebol/central-de-jogos/#/'
  
  page = acessa_pagina(rd,link,espera = 10)
  jogos = pega_bases(rd,page)
  
  con = DBI::dbConnect(RMySQL::MySQL(), 
                       host = "sql10.freesqldatabase.com",dbname="sql10438482",
                       user = "sql10438482", password = "wm9uL5qCPT")
  dbWriteTable(con,'Jogos',jogos,overwrite=T)
  dbDisconnect(con)
  write.table(jogos,'C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt')
  saveRDS(jogos,'C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.RDS')
  
  
  dir = 'C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol'
  repo <- repository(discover_repository(dir))
  git2r::config(repo = repo,
                user.name = "pjoao266",user.email = "pjoao266@gmail.com")
  gitstatus(dir)
  gitadd(dir)
  
  

  
  hoje = Sys.time() %>% 
    str_sub(1,-4)
  gitcommit(dir = dir,msg = paste0('Atualização da base. Data: ',hoje))
  gitpush(dir)
}

system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
library(RSelenium)
library(rvest)
library(tidyverse)
library(lubridate)
library(git2r)
library(stringi)
library(audio)
library(DBI)
library(RMySQL)

source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\atualiza_git.R')
source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\pega_bases.R')
source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\acessa_pagina.R')

rd  = cria_navegador()

cont = 1
audio_b = ifelse(args==1,T,F)

while(1){
  print(paste0('Rodando vez ',cont))
  roda_busca(rd)
  jogos = read.table('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt')
  print(jogos$Situação %>% unique())
  if("Ao Vivo" %in% jogos$Situação){
    if(audio_b) play(load.wave("C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\www\\audio2.wav"))
    tempo = period(second=10,units = 'seconds')

  }else{
    if(audio_b) play(load.wave("C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\www\\audio1.wav"))
    tempo = period(minute=20,units = 'seconds')
  }
  
  print(paste0('Acabou rodar vez ',cont))
  Sys.sleep(tempo %>% as.numeric())
  cont = cont+1
}

