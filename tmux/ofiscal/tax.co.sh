### Setup tax.co repo,
### which (PITFALL) is *also* running in the tax.co.web Docker container
### (like the tax.co.web repo is).
###

tmux -L of rename-window -t sim:0 d-sh
tmux -L of send-keys     -t sim:0         \
  "docker exec -it tax.co.web bash" Enter \
  "cd mnt/tax_co"                   Enter

tmux -L of rename-window -t sim:1 d-py
tmux -L of send-keys     -t sim:1         \
  "docker exec -it tax.co.web bash" Enter \
  "cd mnt/tax_co"                   Enter \
  "ipython"                         Enter

tmux -L of rename-window -t sim:2 GIT
tmux -L of send-keys     -t sim:2         \
  "ssh-agent bash"                  Enter \
  "ssh-add"                         Enter
