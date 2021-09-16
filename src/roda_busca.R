roda_busca = function(){
  library(RSelenium)
  library(rvest)
  library(tidyverse)
  library(git2r)
  rm(list=ls())
  ini = Sys.time()
  source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\atualiza_git.R')
  source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\pega_bases.R')
  source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\acessa_pagina.R')
  
  link = 'https://www.uol.com.br/esporte/futebol/central-de-jogos/#/'
  
  
  page = acessa_pagina(link)
  
  
  jogos = pega_bases(page)
  write.table(jogos,'C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt')
  
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
  
  
  fim = Sys.time()
  fim-ini
}
while(1){
  roda_busca()
  jogos = read.table('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt')
  if("Ao Vivo" %in% jogos$Situação){
    Sys.sleep(30) 
  }else{
    break;
  }
}