#/bin/bash

#TODO Testar se o arquivo ~/.zshrc existe e criar ele caso não exista e adicionar o comando ao final do arquivo `eval "$(starship init zsh)"`
echo "Iniciando configuração dos pacotes de configuração usando o comando \"stow\""
stow . --adopt -v

zsh/zsh-config.sh
