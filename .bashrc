# Non-login, i.e. run on every instance. Place for aliases and functions.

# Creating a symlink between ~/.bashrc and ~/.bash_profile will ensure that the
# same startup scripts run for both login and non-login sessions. Debian's
# ~/.profile sources ~/.bashrc, which has a similar effect.

###########
# History #
###########

export HISTSIZE=9999
export HISTFILESIZE=9999
# not useful and probably doesn't allow removing duplicates
#export HISTTIMEFORMAT="%d.%m.%y %T "
# don't store duplicate lines or lines starting with space in the history
export HISTCONTROL=ignorespace:ignoredups:erasedups

#####################
# Colorful terminal #
#####################

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ] || [ -x /bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto -h --group-directories-first'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

################
# PROMPT (PS1) #
################

# Terminal colors
bldgrn='\e[1;32m'   # Green
txtrst='\e[0m'      # Text Reset

# Smiling prompt :-)
function _exit_code {
    local EXIT="$?"
    local msg=':-)'
    [[ $EXIT -ne 0 ]] && msg=':-('
    echo $msg
}

# \[\] around colors are needed for mintty/cygwin
PS1="\$(_exit_code) \[${bldgrn}\]$ \[${txtrst}\]"

########
# Perl #
########

if [ -d "$HOME/perl5/lib/perl5" ]; then
    [ $SHLVL -eq 1 ] && eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"
fi

# perlbrew
if [ -f "$HOME/perl5/perlbrew/etc/bashrc" ]; then
    source "$HOME/perl5/perlbrew/etc/bashrc"
fi

# add compiled perl6 to PATH
if [ -d "/opt/rakudo-star-2017.10/bin" ]; then
    PATH="/opt/rakudo-star-2017.10/bin:$PATH"
fi
if [ -d "/opt/rakudo-star-2017.10/share/perl6/site/bin" ]; then
    PATH="/opt/rakudo-star-2017.10/share/perl6/site/bin:$PATH"
fi

##########
# Golang #
##########

# add go's bin to PATH
if [ -d "$HOME/go/bin" ]; then
	PATH="$HOME/go/bin:$PATH"
fi
#export PATH=$PATH:$(go env GOPATH)/bin

###########
# Aliases #
###########

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# prevents accidentally clobbering files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# other aliases
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
if [ -e /usr/bin/vim ]; then
    alias vi='vim'
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# add aws to PATH
if [ -d "/home/reisinge/.local/bin" ] ; then
    PATH="/home/reisinge/.local/bin:$PATH"
fi

###############
# Completions #
###############

function _get_git_version() {
    local ver=$(git version | perl -ne '/([\d\.]+)/ && print $1')
    echo $ver
}

# Git completions
if [ ! -f ~/.git-completion-$(_get_git_version).bash ]; then
    curl --silent https://raw.githubusercontent.com/git/git/v$(_get_git_version)/contrib/completion/git-completion.bash --output ~/.git-completion-$(_get_git_version).bash
fi
source ~/.git-completion-$(_get_git_version).bash

# SSH hostnames completion (based on ~/.ssh/config)
if [ -e ~/.ssh_bash_completion ]; then
    source ~/.ssh_bash_completion
fi

# kubernetes (k8s) autocompletion
if which kubectl > /dev/null 2>&1; then
    source <(kubectl completion bash)
    source /usr/share/bash-completion/bash_completion
fi

#########
# Varia #
#########

export VAGRANT_DETECTED_OS="$(uname)"

# In case we use Ansible from checkout (development version)
if [ -f ~/ansible/hacking/env-setup ]; then
    source ~/ansible/hacking/env-setup
fi

# Upgrade my dotfiles but not always
if command -v perl5.18 > /dev/null 2>&1; then   # do we have perl5.18 binary?
    runonce -i 10080 perl5.18 ~/.../... supi    # fix for Mac
else
    runonce -i 10080 ... supi
fi
#runonce -i 10080 install_vim_stuff
runonce -i 10080 ~/git/hub/runp/runp ~/git/hub/runp/commands/install-my-stuff.txt

# Print quote but not always
runonce myquote -s

#[ -f ~/.fzf.bash ] && source ~/.fzf.bash
