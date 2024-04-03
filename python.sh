function pygrep ()
{
    grep -B2 -A2 -rin --colour --exclude-dir .ropeproject --include \*.py "$1" ${2:-.}
}

function pyfiles {
    find ${1:-.} -name \*.py -exec grep . {} + | egrep -v ropeproject | ucol -d: 1 | sort -u
}
