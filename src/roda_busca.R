roda_busca = function(rd){

  page = acessa_pagina(rd,link)
  jogos = pega_bases(rd,page)

  
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

source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\atualiza_git.R')
source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\pega_bases.R')
source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\acessa_pagina.R')

link = 'https://www.uol.com.br/esporte/futebol/central-de-jogos/#/'
rd  = cria_navegador()

cont = 1
audio_b = ifelse(args==1,T,F)

while(1){
  roda_busca(rd)
  
  jogos = read.table('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt')
  if("Ao Vivo" %in% jogos$Situação){
    if(audio_b) play(load.wave("C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\www\\audio2.wav"))
    print(cont)
    Sys.sleep(period(minute=1,units = 'seconds') %>% as.numeric())
  }else{
    if(audio_b) play(load.wave("C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\www\\audio1.wav"))
    print(cont)
    Sys.sleep(period(minute=20,units = 'seconds') %>% as.numeric())
  }
  cont = cont+1
}

