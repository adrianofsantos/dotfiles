#/bin/bash

#TODO Testar se o arquivo ~/.zshrc existe e criar ele caso não exista e adicionar o comando ao final do arquivo `eval "$(starship init zsh)"`
echo "Executando script criar o ~/.zshrc"
if [[ ! -f ~/.zshrc ]]; then
  if [[ "${STOW_ADOPT:-0}" == "1" ]]; then
    echo "Modo --adopt habilitado (STOW_ADOPT=1)."
    stow . -v --adopt --target=$HOME
  else
    echo "Modo --adopt desabilitado. Defina STOW_ADOPT=1 para habilitar."
    stow . -v --target=$HOME
  fi
else
  echo "Arquivo já existe e não precisa ser configurado."
fi
