#!/usr/bin/bash

# alias coming from OMZ
unalias gcp
alias gs='git status'

# It receives as parameters a number of hash commits that wants to be cherry-pick it
# The order must be from the oldest to the newest commit
gcp() {
    hash_commits=$@

    if [[ -n $hash_commits ]]; then
        for p in "$@"; do
            git cherry-pick -x "$p"
            if [[ $? -ne 0 ]]; then
                print_err_msg "[FAIL] Cherry-pick fails for commit $p"
            fi
        done
    else
        echo "No commits given"
    fi
}

# It receives as parameter the number of has commits that wants to be retrieved
# The results of this function copies on the clipboard the amount of hash commits
# asked.
get_commits() {
  local num_commits=$1
  git log -"$num_commits" --reverse --pretty=format:"%H" | tr '\n' ' ' | xclip -sel clip
}
