# virtual environment functions
#
# ve - activate virt env in .venv
#     if ve.sh present, then source it
#
# unve - deactivate virt env
#     restore PYTHONPATH
#     unalias any symbols in _VE_ALIAS
#     unset any symbols in _VE_SET
#     unset any functions in _VE_FUNCTION
#
# jupyter - start jupyter notebook in current virt env or .venv
function _ve {
    if [ -z "$1" ]; then
        VENV=".venv"
    else
        VENV=".venv-$1"
    fi
    if [ ! -d $VENV ]; then
        echo "virtual environment \"$VENV\" not found" 1>&2
        kill -INT $$
    fi
    if [ ! -x $VENV/bin/python ]; then
        echo "the python in virtual environment \"$VENV\" is not executable" 1>&2
        kill -INT $$
    fi
    echo $VENV
}

function _ve_cache {
    if [ ! -z "$_VE_OLD_PYTHONPATH" ]; then
        PYTHONPATH=$_VE_OLD_PYTHONPATH
    fi
    if [ "$_VE_NO_PYTHONPATH" -eq 1 ]; then
        unset PYTHONPATH
    fi
    if [ ! -z "$_VE_ALIAS" ]; then
        for _item in $(echo $_VE_ALIAS); do
            unalias $_item
        done
    fi
    if [ ! -z "$_VE_SET" ]; then
        for _item in $(echo $_VE_SET); do
            unset $_item
        done
    fi
    if [ ! -z "$_VE_FUNCTION" ]; then
        for _item in $(echo $_VE_FUNCTION); do
            unset -f $_item
        done
    fi
    unset _VE_NO_PYTHONPATH _VE_OLD_PYTHONPATH _VE_ALIAS _VE_SET _VE_FUNCTION _item
    if [ "$1" != "-" ]; then
        if [ -z "$PYTHONPATH" ]; then
            _VE_NO_PYTHONPATH=1
        else
            _VE_OLD_PYTHONPATH=$PYTHONPATH
        fi
    fi
}

function ve {
    _ve_cache
    VENV=$(_ve $1)
    source $VENV/bin/activate
    SCRIPT=ve.sh
    if [ -r $SCRIPT ]; then
        source $SCRIPT
    fi
}

function unve {
    _ve_cache -
    if [ ! -z "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

function mk-ve {
    if [ ! -r requirements.txt ]; then
        echo "requirements.txt not found" 1>&2
        kill -INT $$
    fi
    unve
    if [ -z "$1" ]; then
        VENV=".venv"
    else
        VENV=".venv-$1"
    fi
    if [ -d $VENV ]; then
        rm -rf $VENV
    fi
    python3 -m venv $VENV
    $VENV/bin/pip install --no-cache-dir --upgrade pip
    $VENV/bin/pip install -r requirements.txt
    if [ ! -z "$1" ]; then
        if [ -r "requirements-$1.txt" ]; then
            $VENV/bin/pip install -r "requirements-$1.txt"
        fi
    fi
}

function jupyter {
    if [ ! -d notebooks ]; then
        echo "\"notebooks\" directory not found" 1>&2
        kill -INT $$
    fi
    if [ ! -z "$VIRTUAL_ENV" ]; then
        python -m jupyter lab --notebook-dir=notebooks
    else
        _ve_cache
        if [ -r "ve.sh" ]; then
            source ve.sh
        fi
        $(_ve $1)/bin/python -m jupyter lab --notebook-dir=notebooks
        _ve_cache -
    fi
}
