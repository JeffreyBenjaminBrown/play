tmux -L of rename-window -t web:2 GIT
tmux -L of send-keys     -t web:2                       \
  "ssh-agent bash"                                Enter \
  "ssh-add"                                       Enter

# Enter Docker container as appuser, set up Apache, stay in Docker.
tmux -L of send-keys     -t web:0                       \
  "docker exec -it tax.co.web bash"               Enter \
  "bash /mnt/apache2/offline/link.sh"             Enter \
  "service apache2 stop && service apache2 start" Enter \
  "cd /mnt/"                                      Enter

tmux -L of send-keys     -t web:1                       \
  "docker exec -it -u 0 tax.co.web bash"          Enter \
  "cp /mnt/tax_co/cron/*_cron /etc/cron.d"        Enter \
  "echo \"\" > /etc/cron.deny"                    Enter \
  "service cron stop && service cron start"       Enter \
  "exit"                                          Enter
sleep 1 # IMPORTANT: `exit` takes a while.
tmux -L of send-keys     -t web:1                       \
  "docker exec -it tax.co.web bash"               Enter \
  "cd /mnt/"                                      Enter \
  "ipython"                                       Enter
