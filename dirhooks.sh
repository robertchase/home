# Per-directory enter/leave hooks. Lives in ~/git/home, symlinked into ~/shell_custom
# (which ~/.bashrc sources). A directory opts in with .enter.sh / .leave.sh files;
# approve them first with `dirhook-allow`. Runs from PROMPT_COMMAND, so hooks fire at
# the next prompt after a directory change.

: "${DIRHOOK_ENTER:=.enter.sh}"
: "${DIRHOOK_LEAVE:=.leave.sh}"
: "${DIRHOOK_ALLOW_FILE:=${XDG_CONFIG_HOME:-$HOME/.config}/dirhooks/allowed}"

_DIRHOOK_LAST=""

# true if path $1 is directory $2 or lives inside it
_dirhook_within() { [[ $1 == "$2" || $1 == "${2%/}"/* ]]; }

# absolute path of $1 (directory part resolved through symlinks)
_dirhook_abs() {
  local dir base
  dir=$(dirname -- "$1") && base=$(basename -- "$1") || return 1
  dir=$(cd -P -- "$dir" 2>/dev/null && pwd) || { printf '%s\n' "$1"; return 0; }
  [[ $dir == / ]] && dir=""
  printf '%s/%s\n' "$dir" "$base"
}

_dirhook_hash() {
  local out
  if command -v sha256sum >/dev/null 2>&1; then out=$(sha256sum -- "$1")
  else out=$(shasum -a 256 -- "$1"); fi
  printf '%s\n' "${out%% *}"
}

# source a hook script, but only if this exact file content was approved
_dirhook_run() {
  local script q
  script=$(_dirhook_abs "$1")
  [[ -f $script ]] || return 0
  if grep -qxF -- "$(_dirhook_hash "$script")  $script" "$DIRHOOK_ALLOW_FILE" 2>/dev/null; then
    # shellcheck disable=SC1090
    source "$script"
  else
    printf -v q '%q' "$script"
    printf 'dirhooks: skipped %s (not approved, or changed since approval)\n' "$script" >&2
    printf '          review it, then: dirhook-allow %s\n' "$q" >&2
  fi
}

# approve scripts (or, with no args, the hook scripts in the current directory)
dirhook-allow() {
  local -a scripts=("$@")
  local f script entry
  if (( $# == 0 )); then
    for f in "$PWD/$DIRHOOK_ENTER" "$PWD/$DIRHOOK_LEAVE"; do
      if [[ -f $f ]]; then scripts+=("$f"); fi
    done
  fi
  if (( ${#scripts[@]} == 0 )); then
    echo "dirhook-allow: no hook scripts found" >&2
    return 1
  fi
  mkdir -p -- "$(dirname -- "$DIRHOOK_ALLOW_FILE")" && touch -- "$DIRHOOK_ALLOW_FILE" || return 1
  for script in "${scripts[@]}"; do
    script=$(_dirhook_abs "$script")
    if [[ ! -f $script ]]; then
      echo "dirhook-allow: no such file: $script" >&2
      continue
    fi
    entry="$(_dirhook_hash "$script")  $script"
    grep -qxF -- "$entry" "$DIRHOOK_ALLOW_FILE" || printf '%s\n' "$entry" >> "$DIRHOOK_ALLOW_FILE"
    echo "dirhooks: allowed $script"
  done
}

# Run leave scripts for every directory we are no longer inside (deepest
# first), then enter scripts for every directory we are newly inside
# (shallowest first). Moving within a directory's subtree fires nothing.
_dirhook_transition() {
  local old=$1 new=$2 dir
  local -a chain=()

  dir=$old
  while [[ -n $dir ]]; do
    _dirhook_within "$new" "$dir" || _dirhook_run "${dir%/}/$DIRHOOK_LEAVE"
    [[ $dir == / ]] && break
    dir=${dir%/*}; dir=${dir:-/}
  done

  dir=$new
  while true; do
    _dirhook_within "$old" "$dir" || chain=("$dir" ${chain[@]+"${chain[@]}"})
    [[ $dir == / ]] && break
    dir=${dir%/*}; dir=${dir:-/}
  done
  for dir in ${chain[@]+"${chain[@]}"}; do _dirhook_run "${dir%/}/$DIRHOOK_ENTER"; done
}

# runs before every prompt; keeps the exit status of the command you just ran
_dirhook_prompt() {
  local rc=$?
  if [[ $PWD != "$_DIRHOOK_LAST" ]]; then
    local old=$_DIRHOOK_LAST
    _DIRHOOK_LAST=$PWD
    _dirhook_transition "$old" "$PWD"
  fi
  return $rc
}

case ";${PROMPT_COMMAND-};" in
  *";_dirhook_prompt;"*) ;;   # already installed (file sourced twice)
  *) PROMPT_COMMAND="_dirhook_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac
