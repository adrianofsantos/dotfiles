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

# --- Git branch & status (--no-optional-locks avoids lock contention) ---
git_branch=""
git_status_sym=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  # Ahead/behind
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" --no-optional-locks rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" --no-optional-locks rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] && git_status_sym="${git_status_sym}⇡${ahead}"
    [ "$behind" -gt 0 ] && git_status_sym="${git_status_sym}⇣${behind}"
  fi
  # Dirty check
  if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null \
    || ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
    git_status_sym="${git_status_sym}*"
  fi
fi

# --- Nix shell / direnv indicator ---
nix_part=""
if [ -n "$IN_NIX_SHELL" ]; then
  nix_env="${name:-nix}"
  nix_part="   nix:${nix_env}"
elif [ -n "$DIRENV_DIR" ]; then
  direnv_name=$(basename "${DIRENV_DIR#-}")
  nix_part="   direnv:${direnv_name}"
fi

# --- Kubectl context ---
kube_part=""
if command -v kubectl >/dev/null 2>&1; then
  kube_ctx=$(kubectl config current-context 2>/dev/null)
  if [ -n "$kube_ctx" ]; then
    kube_part="   k8s:${kube_ctx}"
  fi
fi

# --- Worktree session (present only while this session runs in a Claude Code-managed worktree) ---
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_part=""
if [ -n "$worktree_name" ]; then
  worktree_part="   wt:${worktree_name}"
  [ -n "$worktree_branch" ] && worktree_part="${worktree_part}(${worktree_branch})"
fi

# --- Context usage indicator ---
# >= 90%: (!)  |  >= 60%: ⚠  |  < 60%: plain
ctx_part=""
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 90 ]; then
    ctx_part=" | ctx:${used_int}%(!)"
  elif [ "$used_int" -ge 60 ]; then
    ctx_part=" | ctx:${used_int}%⚠"
  else
    ctx_part=" | ctx:${used_int}%"
  fi
fi

# --- Time ---
time_now=$(date +%H:%M)

# --- Assemble status line ---
# Format:  󰀵 adriano@machine  ~/path/to/dir   branch*  nix:env  k8s:ctx  wt:name(branch)  | ctx:42%  |  Claude Sonnet  |  14:32
parts="󰀵 ${user}@${host}  ${dir_display}"

if [ -n "$git_branch" ]; then
  parts="${parts}   ${git_branch}"
  [ -n "$git_status_sym" ] && parts="${parts} ${git_status_sym}"
fi

[ -n "$nix_part" ] && parts="${parts}${nix_part}"
[ -n "$kube_part" ] && parts="${parts}${kube_part}"
[ -n "$worktree_part" ] && parts="${parts}${worktree_part}"

parts="${parts}${ctx_part}  |  ${model}  |  ${time_now}"

# --- Rate limits (5h rolling + 7d weekly) & session cost ---
# rate_limits is absent for non-subscription accounts and until the first API response
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# >= 90%: (!)  |  >= 60%: ⚠  |  < 60%: plain (mirrors ctx_part thresholds above)
quota_sym() {
  if [ "$1" -ge 90 ]; then printf '(!)'
  elif [ "$1" -ge 60 ]; then printf '⚠'
  fi
}

usage_part=""
if [ -n "$five_h_pct" ]; then
  five_h_int=${five_h_pct%.*}
  five_h_reset_fmt=""
  [ -n "$five_h_reset" ] && five_h_reset_fmt=" (reset $(date -r "$five_h_reset" +%H:%M))"
  usage_part="5h:${five_h_int}%$(quota_sym "$five_h_int")${five_h_reset_fmt}"
fi
if [ -n "$week_pct" ]; then
  week_int=${week_pct%.*}
  week_reset_fmt=""
  [ -n "$week_reset" ] && week_reset_fmt=" (reset $(date -r "$week_reset" +"%a %H:%M"))"
  usage_part="${usage_part:+${usage_part}  }7d:${week_int}%$(quota_sym "$week_int")${week_reset_fmt}"
fi
if [ -n "$cost_usd" ]; then
  cost_fmt=$(printf '$%.2f' "$cost_usd")
  duration_fmt=""
  if [ -n "$duration_ms" ]; then
    duration_sec=$((duration_ms / 1000))
    duration_fmt=" ($((duration_sec / 60))m$((duration_sec % 60))s)"
  fi
  usage_part="${usage_part:+${usage_part}  |  }${cost_fmt}${duration_fmt}"
fi

# --- Session: reasoning effort, fast mode, prompt cache efficiency, diff size ---
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
fast_mode_on=$(echo "$input" | jq -r 'if .fast_mode then "1" else empty end')
cache_hit_ratio=$(echo "$input" | jq -r '.prompt_cache.hit_ratio // empty')
cache_warm=$(echo "$input" | jq -r 'if .prompt_cache.warm then "1" else empty end')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

session_part=""
[ -n "$effort_level" ] && session_part="effort:${effort_level}"
[ -n "$fast_mode_on" ] && session_part="${session_part:+${session_part}  }⚡fast"
if [ -n "$cache_hit_ratio" ]; then
  cache_pct=$(awk -v r="$cache_hit_ratio" 'BEGIN { printf "%d", r * 100 }')
  cache_state="cold"
  [ -n "$cache_warm" ] && cache_state="warm"
  session_part="${session_part:+${session_part}  }cache:${cache_pct}%(${cache_state})"
fi
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  session_part="${session_part:+${session_part}  }+${lines_added:-0}/-${lines_removed:-0}"
fi

# --- daily.dev headlines (second line, plugin-managed) ---
daily_dev_plugin_dir="$HOME/.claude/plugins/cache/daily-dev/daily-dev"
daily_dev_line=""
if [ -d "$daily_dev_plugin_dir" ] && command -v node >/dev/null 2>&1; then
  daily_dev_script_dir=$(command ls -td "$daily_dev_plugin_dir"/*/ 2>/dev/null | head -1)
  if [ -n "$daily_dev_script_dir" ] && [ -f "${daily_dev_script_dir}statusline/statusline.mjs" ]; then
    # Strip model to avoid duplicating it (already shown on the first line)
    daily_dev_input=$(printf '%s' "$input" | jq -c 'del(.model)')
    daily_dev_line=$(printf '%s' "$daily_dev_input" | node "${daily_dev_script_dir}statusline/statusline.mjs" 2>/dev/null)
  fi
fi

output="$parts"
[ -n "$usage_part" ] && output="${output}
${usage_part}"
[ -n "$session_part" ] && output="${output}
${session_part}"
[ -n "$daily_dev_line" ] && output="${output}
${daily_dev_line}"

printf '%s' "$output"
