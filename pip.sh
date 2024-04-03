function pip-required-by {
    pip freeze |
    awk -F\= '{print $1}' |
    xargs pip show |
    awk -F: '
        $1 == "Name" {
            name = $2
        }
        $1 == "Required-by" {
            print name, $2
        }
    ' | grep $1
}
