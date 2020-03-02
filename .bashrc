# Non-login, i.e. run on every instance. Place for aliases and functions.

# Creating a symlink between ~/.bashrc and ~/.bash_profile will ensure that the
# same startup scripts run for both login and non-login sessions. Debian's
# ~/.profile sources ~/.bashrc, which has a similar effect.

###########
# History #
###########

export HISTSIZE=99999
export HISTFILESIZE=99999
# don't store duplicate lines or lines starting with space in the history
export HISTCONTROL=ignorespace:ignoredups:erasedups

# Search history with peco. Don't run cmmand from h just store it into history.
function h() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi

    # awk removes duplicate lines (even not adjacent) and keeps the original order
    local cmd=$(history | tac | cut -c 8- | awk '!seen[$0]++' | peco)

    history -s "$cmd" # add $cmd to history

    #echo $cmd
    #$cmd
}

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

###########
# Aliases #
###########

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ] || [ -x /bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto -h --group-directories-first'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias l='ls -CF'
alias ll='ls -l'
alias la='ls -A'

# prevent accidentally clobbering files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# other aliases
alias j='jobs -l'
if [ -e /usr/bin/vim ]; then
    alias vi='vim'
fi

########
# PATH #
########

# add to PATH the dir where go binary is installed
if [ -d /usr/local/go/bin ]; then
    PATH="/usr/local/go/bin:$PATH"
fi

# add go's bin to PATH
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
    #PATH=$PATH:$(go env GOPATH)/bin
fi

# add aws to PATH
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# dedup PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

###############
# Completions #
###############

function _get_git_version() {
    local ver=$(git version | perl -ne '/([\d\.]+)/ && print $1')
    echo $ver
}

# Download and source git completion
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
fi
if [ -e /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi

################
# PROMPT (PS1) #
################

# Terminal colors. \[\] around colors are needed for mintty/cygwin.
bldred='\[\e[31m\]'     # Red
bldgrn='\[\e[1;32m\]'   # Green
txtrst='\[\e[0m\]'      # Text Reset

# Smiling prompt
function _ps1_exit_code {
    local EXIT="$?"
    local msg='(-:'
    [[ $EXIT -ne 0 ]] && msg=')-:'
    echo $msg
}

# Download and source git prompt
if [ ! -f ~/.git-prompt-$(_get_git_version).sh ]; then
    curl --silent https://raw.githubusercontent.com/git/git/v$(_get_git_version)/contrib/completion/git-prompt.sh --output ~/.git-prompt-$(_get_git_version).sh
fi
source ~/.git-prompt-$(_get_git_version).sh

# git prompt (__git_ps1) configuration
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
#GIT_PS1_SHOWUPSTREAM="auto name verbose git"

# how long the working path dir (\w) should be
PROMPT_DIRTRIM=3

# K8s context in PS1. My alternative to https://github.com/jonmosco/kube-ps1.
function _k8s_context {
    if [[ -f $HOME/.kube/config ]]; then
        local CTX=$(kubectl config view --minify --output json | jq '.contexts[] | .name')
        echo $CTX | perl -wpe 's/"/[/' | perl -wpe 's/"/]/'
    else
        echo -e '\b' # remove char (whitespace)
    fi
}

PS1="\$(_ps1_exit_code) \h \w\$(__git_ps1 ' (%s)') \$(_k8s_context) ${bldgrn}$ ${txtrst}"

# https://stackoverflow.com/questions/10517128/change-gnome-terminal-title-to-reflect-the-current-directory
PROMPT_COMMAND='echo -ne "\033]0;$(basename $PWD)\007"'

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
    runonce -i 20160 perl5.18 ~/.../... supi    # fix for Mac
else
    runonce -i 20160 ... supi
fi

# Install my stuff but not always
#runonce -i 20160 install_vim_stuff
runonce -i 20160 ~/bin/runp ~/git/hub/runp/commands/install-my-stuff.txt

# Print quote but not always
runonce myquote -s

#[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Open my workshop (vim version)
function work () {
    local proj=$(find -L \
        ~/github ~/gitlab ~/go/src/github.com/jreisinger \
        -maxdepth 1 -type d | peco)
    cd $proj
    git-sync
}
