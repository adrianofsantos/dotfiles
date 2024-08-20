#/bin/bash

#TODO Testar se o arquivo ~/.zshrc existe e criar ele caso não exista e adicionar o comando ao final do arquivo `eval "$(starship init zsh)"`
echo "Executando script criar o ~/.zshrc"
if [[ ! -f ~/.zshrc ]]; then
  stow . -v --adopt --target=$HOME
else
  echo "Arquivo já existe e não precisa ser configurado."
fi
