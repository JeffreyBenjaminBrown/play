docker start pension

tmux -L of send-keys -t pensions:0     \
  "docker exec -it pension bash" Enter \
  "cd mnt/"                      Enter

tmux -L of send-keys -t pensions:1     \
  "docker exec -it pension bash" Enter \
  "cd mnt/"                      Enter \
  "ipython3"                     Enter

tmux -L of send-keys -t pensions:2     \
  "ssh-agent bash"               Enter \
  "ssh-add"                      Enter
