### PITFALL:
###
# tax.co.web and tax.co share the same Docker container.

### USAGE
###
# The docker container,
# and the "of" tmux session,
# should already be running.
# Run this script from anywhere.

tmux -L of kill-session -t 0

docker start tax.co.web
docker start unir
docker start pgn

DIR=~/code/git_play/tmux/

$DIR/ofiscal/tax.co.web.sh
$DIR/ofiscal/tax.co.sh
$DIR/ofiscal/pgn.sh
$DIR/ofiscal/unir.sh
#$DIR/ofiscal/cities.sh
#$DIR/ofiscal/pension.sh
