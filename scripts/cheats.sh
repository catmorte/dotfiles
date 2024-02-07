#!/usr/bin/env bash
types=('language' 'utility')
selected_type=$(printf "%s\n" "${types[@]}" | fzf)
if [[ -z $selected_type ]]; then
    exit 0
fi
if [[ $selected_type == 'language' ]]; then
    languages=('c' 'cpp' 'golang' 'python' 'typescript' 'zsh' 'tmux' 'lua' 'bash' 'css' 'html' 'javascript' 'ruby')
    selected=$(printf "%s\n" "${languages[@]}" | fzf)
    if [[ -z $selected ]]; then
        exit 0
    fi
    read -p "Enter Query: " query
    query=$(echo $query | tr ' ' '+')
    tmux neww bash -c "curl cht.sh/$selected/$query | less"
else
    utils=('curl' 'wget' 'vi' 'vim' 'grep' 'awk' 'sed' 'find' 'ls' 'cat' 'tail' 'head' 'tar' 'gzip' 'less' 'git' 'ssh' 'tmux' 'htop' 'top' 'ps' 'kill' 'docker' 'kubectl' 'zip')
    selected=$(printf "%s\n" "${utils[@]}" | fzf)
    if [[ -z $selected ]]; then
        exit 0
    fi
    read -p "Enter Query: " query
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
fi
