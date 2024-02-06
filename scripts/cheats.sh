#!/usr/bin/env bash
languages=('c' 'cpp' 'golang' 'python' 'typescript' 'zsh' 'tmux' 'lua' 'bash' 'css' 'html' 'javascript' 'ruby')
utils=('curl' 'wget' 'vi' 'vim' 'grep' 'awk' 'sed' 'find' 'ls' 'cat' 'tail' 'head' 'tar' 'gzip' 'less' 'git' 'ssh' 'tmux' 'htop' 'top' 'ps' 'kill' 'docker' 'kubectl' 'zip' 'tmux')
selected=$(printf "%s\n" "${languages[@]}" "${utils[@]}" | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if [[ ${languages[@]} =~ $selected ]]; then
    query=$(echo $query | tr ' ' '+')
    tmux neww bash -c "curl cht.sh/$selected/$query | less"
else
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
fi
