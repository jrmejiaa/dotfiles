#!/usr/bin/bash

#
# This file has some function helpers while working with bitbake
#

alias ds='devtool status'

# Print an error message with a potential banner if a second parameter
# is given
print_err_msg() {
    err_msg="$1"
    show_banner="$2"
    banner="------------------------------------------------------------"
    red_bold="\x1b[31;1m"
    reset="\x1b[0m"
    if [ -n "$show_banner" ]; then
        echo "${red_bold}${banner}\n${err_msg}\n${banner}${reset}"
    else
        echo "${red_bold}${err_msg}${reset}"
    fi
    return 1
}

# It receives an array of recipes that wants to be reset
# the recipes needs to be on the devtool workspace
devr() {
    params=$@
    _tmp_f="$(mktemp)"

    if [[ -n $params ]]; then
        for p in "$@"; do
            _upper_recipe_n=$(echo "$p" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
            _recipe_dir=$(ds | grep "$p": | sed -n -e 's/^.*: //p')

            echo "${_recipe_dir}" >> "$_tmp_f"
            echo "   [ ${_upper_recipe_n} ]"
            echo "      - Resetting workspace in devtool."
            devtool reset "$p" >> "$_tmp_f" 2>&1
            if [[ $? -ne 0 ]]; then
                print_err_msg "[FAIL]. Please look log in $_tmp_f"
                return 1
            fi
        done
    else
        echo "No recipes given"
    fi

}

# It receives an array of recipes that wants to be modified
# the recipes needs to be available on bitbake context
devm() {
    params=$@

    if [[ -n $params ]]; then
        for p in "$@"; do
            _upper_recipe_n=$(echo "$p" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

            echo "   [ ${_upper_recipe_n} ]"
            echo -n "      - Creating workspace for recipe: "
            _tmp_f="$(mktemp)"
            devtool modify "$p" > "$_tmp_f" 2>&1
            if [[ $? -ne 0 ]]; then
                print_err_msg "[FAIL]. Please look log in $_tmp_f"
                return 1
            else
                echo "\033[32m[SUCCESS]\033[0m"
            fi
        done
    else
        echo "No recipes given"
    fi
}

# It uses devtool finish with dry-run to verify the process
devf() {
    recipe_name="$1"
    layer_dir="$2"
    devtool finish --dry-run "$recipe_name" "$layer_dir"
}

# A wrapper function to finish to make it more easy to run
devff() {
    recipe_name="$1"
    layer_dir="$2"
    devtool finish "$recipe_name" "$layer_dir"
}

# This function will build a workspace recipe given in the first parameter
# with devtool. If there is a second parameter and devtool build succeeded
# it will use the deploy-target subcommand of devtool to send the recipe
# to a target device
devb() {
    recipe_name="$1"
    live_target="$2"
    devtool build "$recipe_name"
    if [ $? -ne 0 ]; then
        print_err_msg "Devtool Build fails for recipe $1" "show_banner"
        return 1
    fi
    if [[ -n "$live_target" ]]; then
        devtool deploy-target "$recipe_name" "$live_target"
        if [ $? -ne 0 ]; then
            print_err_msg "Devtool Deploy fails for recipe $1 on target $2" "show_banner"
            return 1
        fi
    fi
}

# Commit a SRCREV change on a bitbake recipe
commit_srcrev() {
    local diff
    diff=$(git diff --cached --unified=0)

    # Check that the only change is a SRCREV line
    local additions removals
    additions=$(echo "$diff" | grep -c '^+[^+]')
    removals=$(echo "$diff" | grep -c '^-[^-]')
    if [ "$additions" -ne 1 ] || [ "$removals" -ne 1 ]; then
        echo "Error: staged diff contains more than just a SRCREV change" >&2
        return 1
    fi
    if ! echo "$diff" | grep -q '^+SRCREV\|^+SRCREV '; then
        echo "Error: staged change is not a SRCREV update" >&2
        return 1
    fi

    # Extract recipe name from the diff header (filename without version and .bb)
    local recipe_name
    recipe_name=$(echo "$diff" | grep '^+++ b/' | head -1 | sed 's|.*/||; s|_[^_]*\.bb$||')

    # Extract reduced commit hash (first 6 chars of new SRCREV)
    local commit_hash
    commit_hash=$(echo "$diff" | grep '^+SRCREV' | grep -o '"[^"]*"' | tr -d '"' | cut -c1-6)

    # Extract JIRA ticket from branch name (any PROJECT-NUMBER pattern)
    local jira_ticket
    jira_ticket=$(git branch --show-current | grep -o '[A-Z]\{2,\}-[0-9]\+')

    git commit -m "feat(${recipe_name}): Update recipe to last commit ${commit_hash}" -m "id: ${jira_ticket}"
}

