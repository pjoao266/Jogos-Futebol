library(DBI)
library(RMySQL)
rm_accent <- function(str,pattern="all") {
  # Rotinas e fun��es �teis V 1.0
  # rm.accent - REMOVE ACENTOS DE PALAVRAS
  # Fun��o que tira todos os acentos e pontua��es de um vetor de strings.
  # Par�metros:
  # str - vetor de strings que ter�o seus acentos retirados.
  # patterns - vetor de strings com um ou mais elementos indicando quais acentos dever�o ser retirados.
  #            Para indicar quais acentos dever�o ser retirados, um vetor com os s�mbolos dever�o ser passados.
  #            Exemplo: pattern = c("�", "^") retirar� os acentos agudos e circunflexos apenas.
  #            Outras palavras aceitas: "all" (retira todos os acentos, que s�o "�", "`", "^", "~", "�", "�")
  if(!is.character(str))
    str <- as.character(str)
  
  pattern <- unique(pattern)
  
  if(any(pattern=="�"))
    pattern[pattern=="�"] <- "�"
  
  symbols <- c(
    acute = "������������",
    grave = "����������",
    circunflex = "����������",
    tilde = "������",
    umlaut = "�����������",
    cedil = "��"
  )
  
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  
  accentTypes <- c("�","`","^","~","�","�")
  
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str)
  
  return(str)
}

atualiza_sql = function(jogos) {
  con <- dbConnect(RMySQL::MySQL(), host = "db4free.net",
                   dbname="bolao_shiny",user = "pjoao266", password = "12345678")
  
  
  times_especfico = c('Cruzeiro','Brasil','Argentina','Uruguai')
  times_champions = c('PSG','Manchester City','Liverpool','Real Madrid',
                      'Borussia Dortmund','Atl�tico de Madri',
                      'Bayern de Munique','Barcelona','Manchester United',
                      'Juventus', 'Chelsea')
  jogos_sql = jogos %>% 
    filter(Competi��o %in%  c('Brasileir�o','Copa do Brasil', 'Libertadores') | 
             Mandante %in% times_especfico | Visitante %in% times_especfico | 
             (Competi��o == 'Liga dos Campe�es' & (Mandante %in% times_champions |
                                                     Visitante %in% times_champions))) %>% 
    mutate(Mandante = rm_accent(Mandante),
           Visitante = rm_accent(Visitante),
           Competi��o = rm_accent(Competi��o))
  Times = rbind(jogos_sql %>% select(Times = Mandante,Imagem = ImagemMandante),
                jogos_sql %>% select(Times = Visitante,Imagem = ImagemVisitante)) %>% 
    unique() %>% 
    anti_join(dbReadTable(con,"Times"),by=c('Times'='Time'))
  
  
  querys = sprintf("INSERT INTO Times (Time,Imagem) VALUES('%s','%s')", Times$Times,Times$Imagem)
  for (query in querys) {
    dbSendQuery(con,query)
  }
  dbDisconnect(con)
  con <- dbConnect(RMySQL::MySQL(), host = "db4free.net",
                   dbname="bolao_shiny",user = "pjoao266", password = "12345678")
  
  Competicoes = jogos_sql %>% 
    select(Competi��o) %>% 
    unique() %>% 
    anti_join(dbReadTable(con,"Competicoes"),by=c('Competi��o'='Competicao'))
  querys = sprintf("INSERT INTO Competicoes (Competicao) VALUES('%s')", Competicoes$Competi��o)
  for (query in querys) {
    dbSendQuery(con,query)
  }
  
  dbDisconnect(con)
  con <- dbConnect(RMySQL::MySQL(), host = "db4free.net",
                   dbname="bolao_shiny",user = "pjoao266", password = "12345678")
  jogos_padronizados = jogos_sql %>% 
    left_join(dbReadTable(con,"Competicoes") %>% 
                rename(id_competicao = id), by=c('Competi��o' = 'Competicao')) %>% 
    left_join(dbReadTable(con,"Times") %>% 
                rename(id_mand = id), by=c('Mandante' = 'Time')) %>% 
    left_join(dbReadTable(con,"Times") %>% 
                rename(id_visit = id), by=c('Visitante' = 'Time')) %>% 
    select(Dia,Horario,id_competicao,id_mand,GolsMandante,GolsVisitante,id_visit, Status = Situa��o,Minutos) %>% 
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
  
  if(nrow(jogos_atualizar)>0){
    querys = sprintf( 'UPDATE Jogos SET GolsMandante = %d, GolsVisitante = %d, Status = "%s", Minutos = "%s" WHERE id = %d',
                      jogos_atualizar$GolsMandante,jogos_atualizar$GolsVisitante,jogos_atualizar$Status,
                      jogos_atualizar$Minutos,jogos_atualizar$id_jogo)
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
                     jogos_inserir$id_visit,jogos_inserir$Status,ifelse(is.na(jogos_inserir$Minutos),jogos_inserir$Minutos,
                                                                                        jogos_inserir$Minutos))
    querys <- gsub("'NA'", "NULL", querys)
    querys <- gsub("NA", "NULL", querys)
    for (query in querys) {
      dbSendQuery(con,query)
    }
  }
  tabelas = list()
  for (tables in dbListTables(con)) {
    tabela = dbReadTable(con,tables)
    tabelas[[tables]] = tabela
  }
  
  saveRDS(tabelas,paste0('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\backup_sql\\',str_replace_all(now(),':','-'),' - backup_SQL.RDS'))
  dbDisconnect(con)
}
