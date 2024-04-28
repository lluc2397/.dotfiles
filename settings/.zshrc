# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/zsh/"

ZSH_THEME="mygnoster"
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    virtualenv
    tmux
	zsh-syntax-highlighting
    you-should-use
    git
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status virtualenv)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

M2_HOME='/opt/apache-maven-3.9.0'
GO_PATH='/usr/local/go'

if [ -d "$M2_HOME" ]; then
    PATH="$M2_HOME/bin:$PATH"
fi
if [[ -d "$GO_PATH" ]]; then
    export PATH="$PATH:$GO_PATH/bin"
fi

export NOTES="$HOME/Notes/"
export DOTS="$HOME/.dotfiles"
export CONFIG="$DOTS/settings"
export SCRIPT="$DOTS/scripts"
export EDITOR=nvim
. $CONFIG/.bash_alias
. $CONFIG/.bash_functions.sh


if [[ -f "$HOME/.workspace" ]]; then
    source "$HOME/.workspace"
fi
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/lucas/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/lucas/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/lucas/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/lucas/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#
eval `dircolors /home/lucas/.dir_colors/dircolors`

# Turso
export PATH="/home/lucas/.turso:$PATH"
