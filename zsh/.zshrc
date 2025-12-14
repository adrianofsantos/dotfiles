[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh

eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Custom variable
# Editor
export EDITOR="nvim"
export VISUAL="nvim"
# NIX
export NIX_CONF_DIR=$HOME/.config/nix
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/adrianofsantos/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

