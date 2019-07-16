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

# Terminal colors
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m' # Black - Background
bakred='\e[41m' # Red
badgrn='\e[42m' # Green
bakylw='\e[43m' # Yellow
bakblu='\e[44m' # Blue
bakpur='\e[45m' # Purple
bakcyn='\e[46m' # Cyan
bakwht='\e[47m' # White
txtrst='\e[0m' # Text Reset

################
# PROMPT (PS1) #
################

# Git stuff in prompt
function _git_info {
    git status > /dev/null 2>&1 || return
    local msg=$(git branch | perl -ne 'print "$_" if s/^\*\s+// && chomp')
    local status_lines=$(git status --porcelain | wc -l)
    [[ $status_lines -ne 0 ]] && msg="$msg !"
    git status | grep -q push && msg="$msg ^"
    git status | grep -q pull && mgs="$msg v"
    echo $msg
}

# Backgroup jobs in prompt
function _n_jobs {
    local cnt=$(jobs | grep -E '\[[:0-9:]]' | wc -l)
    echo $cnt
}

# Smiling prompt (-:
function _exit_code {
    local EXIT="$?"
    local msg=':-)'
    [[ $EXIT -ne 0 ]] && msg=':-('
    echo $msg
}

# Number of trailing directory components to retain when expanding the \w and \W prompt string escapes
export PROMPT_DIRTRIM=2

# \[\] around colors are needed for mintty/cygwin
PS1="\$(_exit_code) \[${txtcyn}\]\h\[${txtrst}\] \W [\$(_git_info)] \$(_n_jobs) \[${bldgrn}\]$ \[${txtrst}\]"

# Show dir path in (Gnome) terminal emulator
# https://stackoverflow.com/questions/10517128/change-gnome-terminal-title-to-reflect-the-current-directory
PROMPT_COMMAND='echo -ne "\033]0;$(pwd | perl -pe '\''$home=$ENV{HOME} ; s#$home#~#'\'')\007"'

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

#####################
# Various functions #
#####################

# Open my workshop (vim version)
function workv () {
    local proj=$(find \
        ~/git/hub ~/git/lab ~/go/src/github.com/jreisinger \
        -maxdepth 1 -type d | peco)
    cd $proj
    git pull
    vim
}

# Just take me the the project dir and pull
function work () {
    local proj=$(find \
        ~/git/hub ~/git/lab ~/go/src/github.com/jreisinger \
        -maxdepth 1 -type d | peco)
    cd $proj
    git pull
}

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
