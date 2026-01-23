#/bin/bash

#TODO Testar se o arquivo ~/.zshrc existe e criar ele caso não exista e adicionar o comando ao final do arquivo `eval "$(starship init zsh)"`
echo "Iniciando configuração dos pacotes de configuração usando o comando \"stow\""
if [[ "${STOW_ADOPT:-0}" == "1" ]]; then
  echo "Modo --adopt habilitado (STOW_ADOPT=1)."
  stow . --adopt -v
else
  echo "Modo --adopt desabilitado. Defina STOW_ADOPT=1 para habilitar."
  stow . -v
fi

zsh/zsh-config.sh
