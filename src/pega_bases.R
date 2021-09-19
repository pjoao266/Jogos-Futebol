pega_bases = function(rd,page){
  dias_com_jogo <- page %>% 
    html_nodes('.match-center-item')
  datas_dias = dias_com_jogo %>% 
    html_attr('data-ts')
  
  jogos = read.table('C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol\\data\\base_tabelaDeJogos.txt',header = T)
  
  jogos =  jogos %>% 
    filter(!(Dia %in% datas_dias))
  
  
  for (indicedia in 1:length(dias_com_jogo)) {
    dia = dias_com_jogo[indicedia]
    data = dia %>% 
      html_attr('data-ts')
    
    jogos_html =  dia %>% 
      html_nodes('.match-wrapper')
    
    for (indice_jogos in 1:length(jogos_html)) {
      jogo = jogos_html[indice_jogos]
      info_jogos = ((jogo %>% 
                       html_attr('data-cfg') %>% 
                       str_split('\\"'))[[1]] %>%
                      paste0(collapse = '') %>% 
                      str_replace_all('\\{', '') %>% 
                      str_replace_all(',',replacement = ';') %>% 
                      str_replace(';',',') %>% 
                      str_split(';'))[[1]][c(2,3)] %>% 
        str_split(':')
      
      horario = info_jogos[[1]][2]
      competicao =   info_jogos[[2]][2]
      
      
      info_jogo = jogo %>% 
        html_nodes('.team-score , .team-name, .match-label') %>% 
        html_text() %>% 
        str_trim()
      
      image_pre = 'https://e.imguol.com/futebol/brasoes/40x40/'
      
      imagens = info_jogo[c(2,5)] %>% 
        str_to_lower() %>% 
        str_replace_all(' ','-') %>% 
        str_replace_all("\\(",'') %>% 
        str_replace_all("\\)",'') %>% 
        stri_trans_general(str = ., id = "Latin-ASCII") %>% 
        paste0(image_pre,.,'.png')
      
      
      base_jogos_Dia = data.frame(Dia = data,Horario = horario, Competição = competicao, Mandante = info_jogo[1],
                                  GolsMandante = info_jogo[2],
                                  GolsVisitante = info_jogo[3],Visitante = info_jogo[4],
                                  ImagemMandante = imagens[1],
                                  ImagemVisitante = imagens[2]) %>% 
        mutate_at(c('GolsVisitante','GolsMandante'),function(x) 
          ifelse(x=='-',NA,as.numeric(x)))
      
      base_jogos_Dia = base_jogos_Dia %>% 
        mutate(Resultado = case_when(is.na(GolsMandante)~'N',
                                     GolsMandante>GolsVisitante~'M',
                                     GolsMandante<GolsVisitante~'V',
                                     GolsMandante==GolsVisitante~'E'),
               Situação = case_when(info_jogo[5]=='ao vivo'~'Ao Vivo',
                                    info_jogo[5] %in% c('encerrado','pós-jogo')~'Encerrado',
                                    T~'Não Iniciado'))
      
      
      minutos = NA
      if(base_jogos_Dia$Situação =='Ao Vivo'){
        proximo_link = jogo %>%
          html_nodes('.match-content-score') %>%
          html_attr('href')
        new_page = acessa_pagina(rd,proximo_link)
        texto = NULL
        texto = new_page %>%
          html_nodes('.backgroundLabel > div') %>%
          html_text()
        if(isTRUE(all.equal(texto,character(0)))){
          new_page = acessa_pagina(rd,proximo_link,espera=10)
          
          texto = new_page %>%
            html_nodes('.scoreboard_matchStage_label div') %>%
            html_text()
        }
        
        if(isTRUE(all.equal(texto,character(0)))){
          minutos = new_page %>%
            html_nodes('div') %>%
            html_text()
        }else{
          if(length(texto)>1){
            if(texto[2] %>% str_detect('[0-9]+')){
              adiciona = ifelse(texto[1] == "2º Tempo",45,0)
              minutos = (texto[2] %>%
                           str_split(pattern = '[\\+;]'))[[1]] %>%
                str_extract('[0-9]+') %>%
                as.numeric() %>%  sum()
              minutos = minutos + adiciona
            }else{
              minutos = texto[2]
            }
          }
          else{
            minutos = texto
          }
        }
        
      }
      
      base_jogos_Dia = base_jogos_Dia %>% 
        mutate(Minutos = ifelse(is.null(minutos),'Jogando',minutos)) %>% 
        relocate(c('ImagemMandante','ImagemVisitante'),.after='Minutos')
      jogos = rbind(jogos,base_jogos_Dia)
    }
  }
  return(jogos)
}
