###
### Setup unir
###

tmux -L of send-keys -t web:2       \
  "docker start tax.co.web" Enter

tmux -L of send-keys -t unir:0      \
  "docker start unir"         Enter \
  "docker exec -it unir bash" Enter \
  "cd mnt/"                   Enter

tmux -L of send-keys -t unir:1      \
  "docker start unir"         Enter \
  "docker exec -it unir bash" Enter \
  "cd mnt/"                   Enter \
  "ipython"                   Enter

tmux -L of send-keys -t unir:2      \
  "ssh-agent bash" Enter            \
  "ssh-add"        Enter
