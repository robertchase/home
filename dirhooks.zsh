# Per-directory enter/leave hooks (zsh port of dirhooks.sh). A directory opts in
# with .enter.sh / .leave.sh files; approve them first with `dirhook-allow`. The
# allow list is shared with the bash version. Runs from a precmd hook, so hooks
# fire at the next prompt after a directory change. Hook scripts are sourced by
# zsh, so they must be zsh-compatible.

: "${DIRHOOK_ENTER:=.enter.sh}"
: "${DIRHOOK_LEAVE:=.leave.sh}"
: "${DIRHOOK_ALLOW_FILE:=${XDG_CONFIG_HOME:-$HOME/.config}/dirhooks/allowed}"

typeset -g _DIRHOOK_LAST=""

# true if path $1 is directory $2 or lives inside it
_dirhook_within() { [[ $1 == "$2" || $1 == "${2%/}"/* ]]; }

# absolute path of $1 (directory part resolved through symlinks)
_dirhook_abs() {
  emulate -L zsh
  local dir=${1:h} base=${1:t}
  dir=$(cd -P -- "$dir" 2>/dev/null && pwd) || { print -r -- "$1"; return 0; }
  [[ $dir == / ]] && dir=""
  print -r -- "$dir/$base"
}

_dirhook_hash() {
  emulate -L zsh
  local out
  if (( $+commands[sha256sum] )); then out=$(sha256sum -- "$1")
  else out=$(shasum -a 256 -- "$1"); fi
  print -r -- "${out%% *}"
}

# source a hook script, but only if this exact file content was approved
# (no `emulate -L` here: the hook script should run with the user's options)
_dirhook_run() {
  local script
  script=$(_dirhook_abs "$1")
  [[ -f $script ]] || return 0
  if grep -qxF -- "$(_dirhook_hash "$script")  $script" "$DIRHOOK_ALLOW_FILE" 2>/dev/null; then
    source "$script"
  else
    print -ru2 -- "dirhooks: skipped $script (not approved, or changed since approval)"
    print -ru2 -- "          review it, then: dirhook-allow ${(q)script}"
  fi
}

# approve scripts (or, with no args, the hook scripts in the current directory)
dirhook-allow() {
  emulate -L zsh
  local -a scripts
  scripts=("$@")
  local f script entry
  if (( $# == 0 )); then
    for f in "$PWD/$DIRHOOK_ENTER" "$PWD/$DIRHOOK_LEAVE"; do
      [[ -f $f ]] && scripts+=("$f")
    done
  fi
  if (( ${#scripts} == 0 )); then
    print -u2 "dirhook-allow: no hook scripts found"
    return 1
  fi
  mkdir -p -- "${DIRHOOK_ALLOW_FILE:h}" && touch -- "$DIRHOOK_ALLOW_FILE" || return 1
  for script in "${scripts[@]}"; do
    script=$(_dirhook_abs "$script")
    if [[ ! -f $script ]]; then
      print -ru2 -- "dirhook-allow: no such file: $script"
      continue
    fi
    entry="$(_dirhook_hash "$script")  $script"
    grep -qxF -- "$entry" "$DIRHOOK_ALLOW_FILE" || print -r -- "$entry" >> "$DIRHOOK_ALLOW_FILE"
    print -r -- "dirhooks: allowed $script"
  done
}

# Run leave scripts for every directory we are no longer inside (deepest
# first), then enter scripts for every directory we are newly inside
# (shallowest first). Moving within a directory's subtree fires nothing.
_dirhook_transition() {
  local old=$1 new=$2 dir
  local -a chain

  dir=$old
  while [[ -n $dir ]]; do
    _dirhook_within "$new" "$dir" || _dirhook_run "${dir%/}/$DIRHOOK_LEAVE"
    [[ $dir == / ]] && break
    dir=${dir%/*}; dir=${dir:-/}
  done

  dir=$new
  while true; do
    _dirhook_within "$old" "$dir" || chain=("$dir" "${chain[@]}")
    [[ $dir == / ]] && break
    dir=${dir%/*}; dir=${dir:-/}
  done
  for dir in "${chain[@]}"; do _dirhook_run "${dir%/}/$DIRHOOK_ENTER"; done
}

# runs before every prompt
_dirhook_prompt() {
  if [[ $PWD != "$_DIRHOOK_LAST" ]]; then
    local old=$_DIRHOOK_LAST
    _DIRHOOK_LAST=$PWD
    _dirhook_transition "$old" "$PWD"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dirhook_prompt   # idempotent if this file is sourced twice
