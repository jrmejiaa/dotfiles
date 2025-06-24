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
    fi
    if [[ -n "$live_target" ]]; then
        devtool deploy-target "$recipe_name" "$live_target"
        if [ $? -ne 0 ]; then
            print_err_msg "Devtool Deploy fails for recipe $1 on target $2" "show_banner"
        fi
    fi
}
