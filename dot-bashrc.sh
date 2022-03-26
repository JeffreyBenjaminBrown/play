# This could also have been called `dot-profile.sh`,
# or a few other things.

# Somehow, this line defines the shell prompt.
# Without it, the whole path is shown,
# rather than merely the name of the current folder.
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '

# This prevents git from popping up a ksshaskpass GUI window
# every time I need to authenticate.
unset SSH_ASKPASS
