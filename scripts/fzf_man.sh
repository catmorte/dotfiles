#!/bin/zsh
show_man() {
    compgen -c | fzf | xargs man
}
