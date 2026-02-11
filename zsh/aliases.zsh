# Comandos para kubernetes
alias k=kubectl
alias kctx=kubectx
alias kns=kubens
#alias kc=kubecolor

# Aliases para comando `ls`
alias ls="eza --icons"
alias l="ls --git -l"
alias lt="l --tree --level=2"
alias la="l -a"

# Aliases para comando `cat`
alias cat="bat"

# Aliases para simplificar a digitação
alias v="nvim"
alias lg="lazygit"

# Aliases para comando `git`
alias g="git"
alias gc="git commit"
alias gco="git checkout"
alias ga="git add"

# Nix
alias dr="sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/"

# Suffix extensions
alias -s txt=nvim
alias -s md=nvim
alias -s yaml=nvim
alias -s yml=nvim
alias -s json=nvim

# O alias abaixo provoca o comportamento de sempre abrir o script no editor de texto e não a execução dele.
#alias -s sh=nvim
#

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
