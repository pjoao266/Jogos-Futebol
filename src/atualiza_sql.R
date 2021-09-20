library(DBI)
library(RMySQL)
library(utf8)
atualiza_sql = function(jogos) {
  con = DBI::dbConnect(RMySQL::MySQL(), 
                       host = "sql10.freesqldatabase.com",dbname="sql10438482",
                       user = "sql10438482", password = "wm9uL5qCPT")
  
  
  times_especfico = c('Cruzeiro','Brasil','Argentina','Uruguai','Vasco',
                      'Botafogo')
  times_champions = c('PSG','Manchester City','Liverpool','Real Madrid',
                      'Borussia Dortmund','Atlético de Madri', 'Internazionale',
                      'Bayern de Munique','Barcelona','Manchester United',
                      'Juventus', 'Chelsea')
  jogos_sql = jogos %>% 
    filter(Competição %in%  c('Brasileirão','Copa do Brasil', 'Libertadores','Inglês') | 
             Mandante %in% times_especfico | Visitante %in% times_especfico | 
             (Competição == 'Liga dos Campeões' & (Mandante %in% times_champions |
                                                     Visitante %in% times_champions))) 
  
  Times = rbind(jogos_sql %>% select(Times = Mandante,Imagem = ImagemMandante),
                jogos_sql %>% select(Times = Visitante,Imagem = ImagemVisitante)) %>% 
    unique() %>% 
    mutate(Times = utf8::as_utf8(Times)) %>% 
    anti_join(dbReadTable(con,"Times"),by=c('Times'='Time'))
  rs <- dbSendQuery(con, 'SET NAMES utf8')
  
  
  querys = sprintf("INSERT INTO Times (Time,Imagem) VALUES('%s','%s')", Times$Times,Times$Imagem)
  for (query in querys) {
    dbSendQuery(con,query)
  }
  dbDisconnect(con)
  con = DBI::dbConnect(RMySQL::MySQL(), 
                       host = "sql10.freesqldatabase.com",dbname="sql10438482",
                       user = "sql10438482", password = "wm9uL5qCPT")
  Competicoes = jogos_sql %>% 
    select(Competição) %>% 
    mutate(Competição = utf8::as_utf8(Competição)) %>% 
    unique() %>% 
    anti_join(dbReadTable(con,"Competicoes"),by=c('Competição'='Competicao'))
  
  rs <- dbSendQuery(con, 'SET NAMES utf8')
  querys = sprintf("INSERT INTO Competicoes (Competicao) VALUES('%s')", Competicoes$Competição)
  for (query in querys) {
    dbSendQuery(con,query)
  }
  
  dbDisconnect(con)
  con = DBI::dbConnect(RMySQL::MySQL(), 
                       host = "sql10.freesqldatabase.com",dbname="sql10438482",
                       user = "sql10438482", password = "wm9uL5qCPT")
  
  jogos_padronizados = jogos_sql %>% 
    left_join(dbReadTable(con,"Competicoes") %>% 
                rename(id_competicao = id), by=c('Competição' = 'Competicao')) %>% 
    left_join(dbReadTable(con,"Times") %>% 
                rename(id_mand = id), by=c('Mandante' = 'Time')) %>% 
    left_join(dbReadTable(con,"Times") %>% 
                rename(id_visit = id), by=c('Visitante' = 'Time')) %>% 
    select(Dia,Horario,id_competicao,id_mand,GolsMandante,GolsVisitante,id_visit, Status = Situação,Minutos) %>% 
    mutate(Dia = as.character(dmy(Dia))) %>%
    full_join(dbReadTable(con,"Jogos") %>% 
                select(id_jogo=id,Dia,Horario,id_competicao,id_mand,id_visit,
                       GM = GolsMandante,GV = GolsVisitante,
                       Stat = Status,Minut = Minutos),by=c('Dia','Horario',
                                                           'id_competicao','id_mand','id_visit'))
  
  jogos_atualizar = jogos_padronizados %>%
    filter(!is.na(id_jogo),!(GolsMandante==GM & GolsVisitante==GV & Status==Stat & Minut==Minutos)) %>% 
    select(id_jogo,GolsMandante,GolsVisitante,Status,Minutos)
  jogos_inserir = jogos_padronizados %>%
    filter(is.na(id_jogo))
  
  rs <- dbSendQuery(con, 'SET NAMES utf8')
  if(nrow(jogos_atualizar)>0){
    querys = sprintf( 'UPDATE Jogos SET GolsMandante = %d, GolsVisitante = %d, Status = "%s", Minutos = "%s" WHERE id = %d',
                      jogos_atualizar$GolsMandante,jogos_atualizar$GolsVisitante,jogos_atualizar$Status %>% utf8::as_utf8(),
                      jogos_atualizar$Minutos %>% utf8::as_utf8(),jogos_atualizar$id_jogo)
    querys <- gsub("'NA'", "NULL", querys)
    querys <- gsub("NA", "NULL", querys)
    for (query in querys) {
      dbSendQuery(con,query)
    }
  }

  if(nrow(jogos_inserir)>0){
    querys = sprintf("INSERT INTO Jogos (Dia,Horario,id_competicao,id_mand,GolsMandante,GolsVisitante,id_visit,Status,Minutos) VALUES('%s','%s',%d,%d,%d,%d,%d,'%s','%s')",
                     ymd(jogos_inserir$Dia),jogos_inserir$Horario,jogos_inserir$id_competicao,
                     jogos_inserir$id_mand,jogos_inserir$GolsMandante,jogos_inserir$GolsVisitante,
                     jogos_inserir$id_visit,jogos_inserir$Status %>% utf8::as_utf8(),ifelse(is.na(jogos_inserir$Minutos),jogos_inserir$Minutos,
                                                                                        jogos_inserir$Minutos %>% as.character() %>% 
                                                                                          utf8::as_utf8()))
    querys <- gsub("'NA'", "NULL", querys)
    querys <- gsub("NA", "NULL", querys)
    for (query in querys) {
      dbSendQuery(con,query)
    }
  }
  dbDisconnect(con)
}
