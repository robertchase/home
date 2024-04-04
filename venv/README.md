python venv functions
=====================

This is a collection of functions that assists with using python virtual environments.

## ve
The `ve` function activates the python virtual environment in `.venv` (or in `.venv-$1`).

If a script named `ve.sh` is available, it is sourced. The script can be used to set variables, functions and aliases that might be useful when working with the virtual environment. If `PYTHONPATH` is set in the script, it will be cleaned up when `unve` is run.

 To control what gets cleaned up when `unve` is run, the script can export any of these variables:

* \_VE\_SET&mdash;a list of variables to be `unset` when `unve` is run.
* \_VE\_FUNCTION&mdash;a list of functions to be `unset` when `unve` is run.
* \_VE\_ALIAS&mdash;a list of aliases to be `unaliased` when `unve` is run.

Note: If `ve` is run while another `ve` is active, cleanup will happen before the new environment is activated.

## unve

Clean up any items from the previous `ve` and deactivate the current virtual environment (if any).

## mk-ve

Make a new `.venv` (or `.venv-$1`) and install everything in `requirements.txt` (and, if `$1` is specified, everything in `requirements-$1.txt`).

If a `.venv` directory is present, it is replaced.

Any items from a previous `ve` will be cleaned up. Any active virtual environment will be deactivated.

## jupyter

Start a `jupyter notebook` in the current virtual environment (if activated), or in `.venv` or `.venv-$1`.