#!/usr/bin/env bash
# Claude Code status line — inspired by Starship / Catppuccin Mocha prompt

input=$(cat)

# Extract fields from JSON input
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- User & host ---
user=$(whoami)
host=$(hostname -s)

# --- Directory: truncate to last 3 segments (mirrors Starship truncation_length=3) ---
dir_display=$(echo "$cwd" | awk -F'/' '{
  n = NF
  if (n <= 3) { print $0 }
  else { print "…/" $(n-2) "/" $(n-1) "/" $n }
}')
# Replace $HOME with ~
home="$HOME"
dir_display="${dir_display/#$home/~}"

# --- Git branch & status (skip locks for safety) ---
git_branch=""
git_status_sym=""
if git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null); then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Ahead/behind
  upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] && git_status_sym="${git_status_sym}⇡${ahead}"
    [ "$behind" -gt 0 ] && git_status_sym="${git_status_sym}⇣${behind}"
  fi
  # Dirty check
  if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
    git_status_sym="${git_status_sym}*"
  fi
fi

# --- Context usage indicator ---
ctx_part=""
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 90 ]; then
    ctx_part=" | ctx:${used_int}%(!)"
  elif [ "$used_int" -ge 75 ]; then
    ctx_part=" | ctx:${used_int}%"
  else
    ctx_part=" | ctx:${used_int}%"
  fi
fi

# --- Time ---
time_now=$(date +%H:%M)

# --- Assemble status line ---
# Format:  󰀵 adriano@machine  ~/path/to/dir   branch*  |  Claude 3.5 Sonnet  | ctx:42%  |  14:32
parts="󰀵 ${user}@${host}  ${dir_display}"

if [ -n "$git_branch" ]; then
  parts="${parts}   ${git_branch}"
  [ -n "$git_status_sym" ] && parts="${parts} ${git_status_sym}"
fi

parts="${parts}${ctx_part}  |  ${model}  |  ${time_now}"

printf '%s' "$parts"
