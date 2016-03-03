
function installed()
{
    if [ $# -eq 1 ]; then
        [ "$(type $1)" = "$1 not found" ] || return 0 &&  return 1
    fi
}



# give error nb to get the corresponding error string
function error()
{
    python -c "import os; print os.strerror($?)";
}


