acessa_pagina = function(link){
  rd = rsDriver(browser = 'chrome',port=1234L,
                chromever = '93.0.4577.63')
  cliente = rd$client
  remDr$navigate(link)
  wait = F
  
  while(!wait){
    wait = remDr$executeScript("return document.readyState == 'complete';")[[1]]
  }
  
  page = read_html(remDr$getPageSource()[[1]])
  remDr$close()
  rd$server$stop()
  rm(rd, remDr)
  gc()
  system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
  return(page)
}





