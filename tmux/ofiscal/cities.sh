tmux -L of send-keys -t cities:0      \
  "docker start cities"         Enter \
  "docker exec -it cities bash" Enter \
  "cd mnt/"                     Enter

tmux -L of send-keys -t cities:1      \
  "docker exec -it cities bash" Enter \
  "cd mnt/"                     Enter \
  "ipython"                     Enter

tmux -L of send-keys -t cities:2      \
  "ssh-agent bash"              Enter \
  "ssh-add"                     Enter
