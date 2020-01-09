# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ls colors
alias ls='ls --color=auto'

# Nice PS1 colors
color1="\[\e[38;5;94m\]"
color2="\[\e[38;5;96m\]"
color3="\[\e[38;5;98m\]"
color4="\[\e[38;5;135m\]"
color5="\[\e[38;5;170m\]"
bracecolor="\[\e[38;5;108m\]"
dollarcolor="\[\e[38;5;108m\]"
endcolor="\[\e[m\]"
PS1="$bracecolor[$color1\u$color2@${color3}kaiser:${color4}${KAISER_NAME} $color5\W$endcolor$bracecolor]$dollarcolor\\$\[\e[m\] "

# Vim input (if you want it)
#set -o vi
