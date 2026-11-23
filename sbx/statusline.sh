#!/usr/bin/env bash
# statusLine do Claude Code dentro de sandbox sbx. Configurado pelo
# sbx/bootstrap.sh no ~/.claude/settings.json do sandbox.
#
# O sbx já ocupa o statusLine com `sbx-claude-hook claude-status`, que manda
# o status da sessão pro app do Docker e não imprime nada. Este wrapper
# repassa o mesmo JSON aos dois: o hook do sbx (ele mesmo roda em background
# e retorna na hora) e o claude/statusline-command.sh do repo, que desenha a
# linha no terminal.
input=$(cat)
sbx_hook=/usr/local/bin/sbx-claude-hook
[[ -x "$sbx_hook" ]] && printf '%s' "$input" | "$sbx_hook" claude-status >/dev/null 2>&1
printf '%s' "$input" | bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/claude/statusline-command.sh"
