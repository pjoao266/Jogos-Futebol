library(git2r)
dir = 'C:\\Users\\JoaoPedro\\Arquivos\\Dados\\Maluquices\\JogosFutebol'
repo <- repository(discover_repository(dir))
git2r::config(repo = repo,
              user.name = "pjoao266",user.email = "pjoao266@gmail.com")
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
  cmd = sprintf("git commit -m\"%s\"",msg)
  system(cmd)
}
gitcommit <- function(msg = "commit from Rstudio", dir = getwd()){
  cmd_list <- list(
    cmd1 = tolower(substr(dir,1,2)),
    cmd2 = paste("cd",dir),
    cmd3 = sprintf("git commit -m\"%s\"",msg)
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

gitstatus(dir)
gitadd(dir)
hoje = Sys.time() %>% 
  str_sub(1,-4)
gitcommit(dir = dir,msg = paste0('Atualização da base. Data: ',hoje))

gitpush(dir)
