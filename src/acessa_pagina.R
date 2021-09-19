acessa_pagina = function(rd,link,espera=0){
  cliente = rd$client
  servidor = rd$server
  cliente$navigate(link)
  wait = F
  
  while(!wait){
    wait = cliente$executeScript("return document.readyState == 'complete';")[[1]]
  }
  Sys.sleep(espera)
  page = read_html(cliente$getPageSource()[[1]])
  return(page)
}
cria_navegador = function(){
  rsDriver(browser = 'chrome',port=1237L,
                chromever = '93.0.4577.63',
                geckover = '0.30.0',
                # extraCapabilities = list("chromeOptions" = list(args = list('--headless')))
  ) %>% return()
  
}




