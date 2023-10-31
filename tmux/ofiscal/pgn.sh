###
### Setup unir
###

tmux -L of send-keys -t pgn:0      \
  "docker start pgn"         Enter \
  "docker exec -it pgn bash" Enter \
  "cd mnt/"                  Enter

tmux -L of send-keys -t pgn:1      \
  "docker exec -it pgn bash" Enter \
  "cd mnt/"                  Enter \
  "ipython"                  Enter

tmux -L of send-keys -t pgn:2      \
  "ssh-agent bash"           Enter \
  "ssh-add"                  Enter
