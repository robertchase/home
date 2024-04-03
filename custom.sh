DIR=~/shell_custom
if [ -d $DIR ]
then
    for filename in $DIR/*.sh; do
        source $filename
    done
fi
