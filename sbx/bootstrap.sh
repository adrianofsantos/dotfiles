#!/usr/bin/env bash
# Bootstrap de um sandbox Docker (sbx) com a config pessoal do dotfiles.
# Roda DENTRO do sandbox. Idempotente: pode rodar de novo sem duplicar nada.
#
#   1. Importa o CLAUDE.md global (claude/CLAUDE.md) no ~/.claude/CLAUDE.md
#      gerado pelo sbx, preservando o bloco sbx:guidance
#   2. Instala o gitleaks (apt)
#   3. Aponta core.hooksPath global pro nix/git-hooks deste repo, o mesmo
#      hook de pre-commit que o home-manager aplica no macOS
#   4. Instala os plugins do Claude Code habilitados no claude/settings.json
#      do repo (e os marketplaces extras que eles exigem)
#
# Requisito: o dotfiles montado no sandbox (workspace principal ou extra
# `:ro`), no mesmo caminho absoluto do host. O caminho é derivado da
# localização deste script, então não depende de usuário nem de host.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_CLAUDE_MD="$DOTFILES_DIR/claude/CLAUDE.md"
HOOKS_DIR="$DOTFILES_DIR/nix/git-hooks"
SANDBOX_CLAUDE_MD="$HOME/.claude/CLAUDE.md"

log() { printf '[sbx-bootstrap] %s\n' "$*"; }

if [[ "${IS_SANDBOX:-}" != "1" ]]; then
  log "IS_SANDBOX != 1: este script é só para sandbox sbx. Abortando."
  exit 1
fi

# 1. CLAUDE.md global via @import
import_line="@$GLOBAL_CLAUDE_MD"
if [[ ! -f "$GLOBAL_CLAUDE_MD" ]]; then
  log "ERRO: $GLOBAL_CLAUDE_MD não encontrado (dotfiles montado?)"
  exit 1
fi
mkdir -p "$(dirname "$SANDBOX_CLAUDE_MD")"
if grep -qxF "$import_line" "$SANDBOX_CLAUDE_MD" 2>/dev/null; then
  log "CLAUDE.md: import já presente"
else
  printf '\n%s\n' "$import_line" >> "$SANDBOX_CLAUDE_MD"
  log "CLAUDE.md: import adicionado ($import_line)"
fi

# 2. gitleaks
if command -v gitleaks &>/dev/null; then
  log "gitleaks: já instalado ($(gitleaks version))"
else
  log "gitleaks: instalando via apt"
  sudo apt-get update -qq
  sudo apt-get install -y -qq gitleaks
  log "gitleaks: $(gitleaks version)"
fi

# 3. hook de pre-commit global
current_hooks="$(git config --global --get core.hooksPath || true)"
if [[ "$current_hooks" == "$HOOKS_DIR" ]]; then
  log "git: core.hooksPath já aponta para $HOOKS_DIR"
else
  [[ -n "$current_hooks" ]] && log "git: substituindo core.hooksPath anterior ($current_hooks)"
  git config --global core.hooksPath "$HOOKS_DIR"
  log "git: core.hooksPath = $HOOKS_DIR"
fi

# 4. plugins do Claude Code: o settings.json do sandbox é gerado pelo sbx e
# não traz enabledPlugins/extraKnownMarketplaces do host. A lista sai do
# claude/settings.json do repo (marketplaces extras + plugins com true).
# Falha num plugin não aborta o resto: só avisa.
REPO_SETTINGS="$DOTFILES_DIR/claude/settings.json"
KNOWN_MKT="$HOME/.claude/plugins/known_marketplaces.json"
SANDBOX_SETTINGS="$HOME/.claude/settings.json"
if ! command -v claude &>/dev/null || ! command -v jq &>/dev/null; then
  log "plugins: claude ou jq ausente, pulando"
else
  while IFS=$'\t' read -r name repo; do
    if jq -e --arg n "$name" 'has($n)' "$KNOWN_MKT" &>/dev/null; then
      log "plugins: marketplace $name já presente"
    elif claude plugin marketplace add "$repo" >/dev/null 2>&1; then
      log "plugins: marketplace $name adicionado ($repo)"
    else
      log "plugins: AVISO, falha ao adicionar marketplace $name ($repo)"
    fi
  done < <(jq -r '.extraKnownMarketplaces // {} | to_entries[]
                  | select(.value.source.source == "github")
                  | [.key, .value.source.repo] | @tsv' "$REPO_SETTINGS")

  while read -r plugin; do
    if jq -e --arg p "$plugin" '.enabledPlugins[$p] == true' "$SANDBOX_SETTINGS" &>/dev/null; then
      log "plugins: $plugin já instalado"
    elif out="$(claude plugin install "$plugin" --scope user 2>&1)"; then
      log "plugins: $plugin instalado"
    else
      log "plugins: AVISO, $plugin falhou: $(tail -n1 <<<"$out")"
    fi
  done < <(jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$REPO_SETTINGS")
fi

log "ok. CLAUDE.md e plugins valem a partir da próxima sessão do claude."
