# Non-login, i.e. run on every instance. Place for aliases and functions.

# Creating a symlink between ~/.bashrc and ~/.bash_profile will ensure that the
# same startup scripts run for both login and non-login sessions. Debian's
# ~/.profile sources ~/.bashrc, which has a similar effect.

###########
# History #
###########

export SHELL_SESSION_HISTORY=0 # so history gets saved on Mac
export HISTSIZE=99999
export HISTFILESIZE=99999
# don't store duplicate lines or lines starting with space in the history
export HISTCONTROL=ignorespace:ignoredups:erasedups

# Search history with peco. Don't run cmmand from h just store it into history.
function h {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi

    # awk removes duplicate lines (even not adjacent) and keeps the original order
    local cmd=$(history | $tac | cut -c 8- | awk '!seen[$0]++' | peco)

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
else
  alias ls='ls -G' # Mac
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

# If VScode is not installed create alias to VSCodium
if ! which code > /dev/null 2>&1; then
    alias code=codium
fi

########
# PATH #
########

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

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
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# dedup PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

###############
# Completions #
###############

function _get_git_version {
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

# K8s autocompletion.
if which kubectl > /dev/null 2>&1; then
    source <(kubectl completion bash)
fi
# Linux
if [ -e /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi
# Mac
if [ -e /usr/local/share/bash-completion/bash_completion ]; then
    source /usr/local/share/bash-completion/bash_completion
fi

################
# PROMPT (PS1) #
################

# NOTE: \[\] around colors and other non printable bytes are needed so bash can
# count prompt (PS1) length correctly. Otherwise you get rewritten text.

# K8s context in PS1. My alternative to https://github.com/jonmosco/kube-ps1.
function __k8s_context {
    local ctx=""
    if [[ -n $KUBECONFIG ]] || [[  -f $HOME/.kube/config ]]; then
        ctx=$(kubectl config view --minify --output json 2> /dev/null | jq -r '.["current-context"]')
    fi
    echo "[$ctx]"
}

function __prompt_command {
    # This needs to be first
    local EXIT="$?"

    # Terminal colors
    local red='\[\033[31m\]'
    local grn='\[\033[32m\]'
    local blu='\[\e[0;34m\]'
    local ylw='\[\e[0;33m\]'
    local bldred='\[\e[31m\]'
    local bldgrn='\[\e[1;32m\]'
    local bldblu='\[\e[1;34m\]'
    local txtrst='\[\e[0m\]'
    # Background colors - https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
    local bcgblu='\[\e[48;5;195m\]'

    # Download and source git prompt
    if [ ! -f ~/.git-prompt-$(_get_git_version).sh ]; then
        curl --silent https://raw.githubusercontent.com/git/git/v$(_get_git_version)/contrib/completion/git-prompt.sh --output ~/.git-prompt-$(_get_git_version).sh
    fi
    source ~/.git-prompt-$(_get_git_version).sh

    # git prompt (__git_ps1) configuration
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1

    # how long the working path dir (\w) should be
    PROMPT_DIRTRIM=3

    PS1="${blu}\h${txtrst} ${bcgblu}\w\$(__git_ps1 '(%s)')${txtrst}"

    # Add color when in context where a bit of caution is appropriate
    local k8s_context=$(__k8s_context)
    if [[ $k8s_context =~ (.*)(prod|admin)(.*) ]]; then
        PS1+=" ${BASH_REMATCH[1]}${ylw}${BASH_REMATCH[2]}${txtrst}${BASH_REMATCH[3]}"
    else
        PS1+=" $k8s_context"
    fi

    # Set terminal tab title
    echo -ne "\033]0;$(hostname):$(basename $PWD)\007"

    # Set color based on the command's exit code
    if [[ $EXIT -eq 0 ]]; then
        PS1+="${bldgrn} $ ${txtrst}"
    else
        PS1+="${bldred} $ ${txtrst}"
    fi
}

# Function that runs after each command to generate the prompt. Adapted from
# https://stackoverflow.com/questions/16715103/bash-prompt-with-last-exit-code
PROMPT_COMMAND=__prompt_command

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
    runonce -i 20160 ~/.../... supi
fi

# Install my stuff but not always
#runonce -i 20160 install_vim_stuff
runonce -i 20160 runp ~/git/hub/runp/commands/install-my-stuff.txt

# Print quote but not always
runonce myquote -s

# Open my workshop
function work {
    local proj=$(find -L \
        ~/git/hub ~/git/lab ~/data ~/temp \
        -maxdepth 1 -type d | peco)
    cd $proj
    # Run git-sync if it's a git repo.
    if git status > /dev/null 2>&1; then
        echo "---[ Running git-sync ]---"
        git-sync
    fi
    # Run init script if present and executable.
    if [[ -x ./work.sh ]]; then
        echo "---[ Running ./work.sh ]---"
        ./work.sh
    fi
}

# No k8s cluster configuration selected by default.
unset KUBECONFIG

# Allow me to select from multiple k8s clusters configurations.
function k {
    local k8s_config=$(find $HOME/.kube -type f \( -iname '*.yaml' -o -name '*.yml' \) | peco)
    KUBECONFIG=$k8s_config
    export KUBECONFIG
}

###########
# MacBook #
###########

machine=$(uname -s)
if [[ $machine == "Darwin" ]]; then
    # Stop saying that zsh is the new default.
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # So Python can find CA certificates.
    ALL_CA_CERTIFICATES="/usr/local/share/ca-certificates/cacert.pem"
    if [[ -f "$ALL_CA_CERTIFICATES" ]]; then
        export REQUESTS_CA_BUNDLE=$ALL_CA_CERTIFICATES
    fi
fi
