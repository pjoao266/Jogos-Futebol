library(rvest)
library(tidyverse)
library(git2r)
rm(list=ls())
link = 'https://www.uol.com.br/esporte/futebol/central-de-jogos/'

page <- read_html(link)
page

dias_com_jogo <- page %>% 
  html_nodes('.match-center-item')
datas_dias = dias_com_jogo %>% 
  html_attr('data-ts')

jogos = read.table('base_tabelaDeJogos.txt') %>% 
  filter(!(Dia %in% datas_dias))

for (indicedia in 1:length(dias_com_jogo)) {
  dia = dias_com_jogo[indicedia]
  data = dia %>% 
    html_attr('data-ts')
  
  jogos_dia = dia %>% 
    html_nodes('.team-score , .team-name') %>% 
    html_text()
  
  mandantes = jogos_dia[seq(from=1,to = length(jogos_dia),by = 4)]
  golsmand = jogos_dia[seq(from=2,to = length(jogos_dia),by = 4)]
  golsvisit = jogos_dia[seq(from=3,to = length(jogos_dia),by = 4)]
  visitantes = jogos_dia[seq(from=4,to = length(jogos_dia),by = 4)]
  
  base_jogos_Dia = data.frame(Dia = data, Mandante = mandantes,GolsMandante = golsmand,
                              GolsVisitante = golsvisit,Visitante = visitantes) %>% 
    mutate_at(c('GolsVisitante','GolsMandante'),function(x) 
      ifelse(x=='-',NA,as.numeric(x)))
  
  base_jogos_Dia = base_jogos_Dia %>% 
    mutate(Resultado = case_when(is.na(GolsMandante)~'N',
                                 GolsMandante>GolsVisitante~'M',
                                 GolsMandante<GolsVisitante~'V',
                                 GolsMandante==GolsVisitante~'E'))
  jogos = rbind(jogos,base_jogos_Dia)
}
write.table(jogos,'base_tabelaDeJogos.txt')

hoje = Sys.time() %>% 
  str_sub(1,-4)
git2r::config(user.name = "pjoao266",user.email = "pjoao266@gmail.com")

gitcommit <- function(msg = "commit from Rstudio", dir = getwd()){
  cmd = sprintf("git commit -m\"%s\"",msg)
  system(cmd)
}
# Git status.
gitstatus <- function(dir = getwd()){
  cmd_list <- list(
    cmd1 = tolower(substr(dir,1,2)),
    cmd2 = paste("cd",dir),
    cmd3 = "git status"
  )
  cmd <- paste(unlist(cmd_list),collapse = " & ")
  shell(cmd)
}

# Git add.
gitadd <- function(dir = getwd()){
  cmd_list <- list(
    cmd1 = tolower(substr(dir,1,2)),
    cmd2 = paste("cd",dir),
    cmd3 = "git add --all"
  )
  cmd <- paste(unlist(cmd_list),collapse = " & ")
  shell(cmd)
}

# Git commit.
gitcommit <- function(msg = "commit from Rstudio", dir = getwd()){
  cmd_list <- list(
    cmd1 = tolower(substr(dir,1,2)),
    cmd2 = paste("cd",dir),
    cmd3 = paste0("git commit -am ","'",msg,"'")
  )
  cmd <- paste(unlist(cmd_list),collapse = " & ")
  shell(cmd)
}

# Git push.
gitpush <- function(dir = getwd()){
  cmd_list <- list(
    cmd1 = tolower(substr(dir,1,2)),
    cmd2 = paste("cd",dir),
    cmd3 = "git push"
  )
  cmd <- paste(unlist(cmd_list),collapse = " & ")
  shell(cmd)
}
gitadd()
gitcommit(msg = paste0('Atualização da base. Data: ',hoje))
gitpush()