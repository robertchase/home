alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias lt='ls $LS_OPTIONS -lt'
alias la='ls $LS_OPTIONS -la'
alias l='ls $LS_OPTIONS -lA'

alias nv="nvim"
alias viz='nvim $(fzf --preview "bat --style=numbers --color=always --theme=ansi --line-range :500 {}")'

alias lsof-listen="lsof -itcp -stcp:listen -nP"

alias lc="pygount --format=summary"
