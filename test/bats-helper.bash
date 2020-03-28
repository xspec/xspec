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
