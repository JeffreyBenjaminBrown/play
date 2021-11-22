### USAGE
###
# The docker container,
# and the "of" tmux session,
# should already be running.
# Run this script from anywhere.

tmux -L of kill-session -t 0

tmux -L of send-keys -t web:0 \
     "docker start tax.co.web" Enter


###
### Setup tax.co.web
###

# Enter Docker container as appuser, set up Apache, stay in Docker.
tmux -L of rename-window -t web:0 d-sh
tmux -L of send-keys     -t web:0                       \
  "docker exec -it tax.co.web bash"               Enter \
  "bash /mnt/apache2/offline/link.sh"             Enter \
  "service apache2 stop && service apache2 start" Enter \
  "cd /mnt/"                                      Enter

# Enter Docker container as root, set up cron, exit.
tmux -L of send-keys     -t web:1                 \
  "docker exec -it -u 0 tax.co.web bash"    Enter \
  "cp /mnt/tax_co/cron/*_cron /etc/cron.d"  Enter \
  "echo \"\" > /etc/cron.deny"              Enter \
  "service cron stop && service cron start" Enter \
  "exit"                                    Enter

tmux -L of rename-window -t web:2 GIT
tmux -L of send-keys     -t web:2 \
     "ssh-agent bash" Enter       \
     "ssh-add"        Enter


###
### Setup tax.co.web
###

tmux -L of rename-window -t sim:0 d-sh
tmux -L of send-keys     -t sim:0            \
     "docker exec -it tax.co.web bash" Enter \
     "cd mnt/tax_co"                   Enter

tmux -L of rename-window -t sim:1 d-py
tmux -L of send-keys     -t sim:1            \
     "docker exec -it tax.co.web bash" Enter \
     "cd mnt/tax_co"                   Enter \
     "python3"                         Enter

tmux -L of rename-window -t sim:2 GIT
tmux -L of send-keys     -t sim:2 \
     "ssh-agent bash" Enter       \
     "ssh-add"        Enter
