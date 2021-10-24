assert_regex() {
    if [ "$#" -ne 2 ]; then
        echo "Invalid number of arguments: $#"
        return 1
    fi

    if [[ "" =~ $2 ]]; then
        echo "Regex matches zero-length string: $2"
        return 1
    fi

    [[ $1 =~ $2 ]]
}

# https://www.linuxjournal.com/content/normalizing-path-names-bash
normalize_path() {
    # Remove all /./ sequences.
    local path=${1//\/.\//\/}

    # Remove dir/.. sequences.
    while [[ $path =~ ([^/][^/]*/\.\./) ]]; do
        path=${path/${BASH_REMATCH[0]}/}
    done
    echo "$path"
}

assert_leaf_dir_not_exist() {
    local normalized
    normalized=$(normalize_path "$1")

    local parent
    parent=$(dirname -- "${normalized}")

    # Checks to see if the parent dir of the specified dir exists...
    if [ -d "${parent}/" ]; then
        # ...but the specified dir does not exist.
        if [ -d "$1/" ]; then
            echo "Exist (Expected not to exist): $1/"
        else
            return 0
        fi
    else
        echo "Not exist (Expected to exist): ${parent}/"
    fi

    return 1
}

myrun() {
    run --keep-empty-lines -- "$@"
    # To print $output, use --print-output-on-failure and/or --verbose-run Bats command line flags

    # Revert a confusing behavior of --keep-empty-lines: https://github.com/bats-core/bats-core/blob/v1.5.0/test/run.bats#L21-L27
    # shellcheck disable=SC2154
    if [ ${#lines[@]} -ge 2 ] && [ "${lines[${#lines[@]} - 1]}" == "" ]; then
        unset 'lines[${#lines[@]}-1]'
    fi
}
