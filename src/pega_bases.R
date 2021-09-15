library(rvest)
library(tidyverse)



page <- read_html(link)
page

pega_bases = function(page){
  dias_com_jogo <- page %>% 
    html_nodes('.match-center-item')
  datas_dias = dias_com_jogo %>% 
    html_attr('data-ts')
  dia = dias_com_jogo[7]
  
  jogos = read.table('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt') %>% 
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
    return(jogos)
  }
}


source('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\src\\atualiza_git.R')
