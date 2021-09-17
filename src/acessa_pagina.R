acessa_pagina = function(link){
  rd = rsDriver(browser = 'chrome',port=1235L,
                chromever = '93.0.4577.63',
                geckover = '0.29.1',
                extraCapabilities = list("chromeOptions" = list(args = list('--headless'))))
  cliente = rd$client
  servidor = rd$server
  cliente$navigate(link)
  wait = F
  
  while(!wait){
    wait = cliente$executeScript("return document.readyState == 'complete';")[[1]]
  }
  page = read_html(cliente$getPageSource()[[1]])
  cliente$close()
  servidor$stop()
  rm(rd, cliente,servidor)
  gc()
  system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
  return(page)
}





