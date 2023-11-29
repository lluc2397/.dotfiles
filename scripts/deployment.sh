#!/bin/bash
function git_save_everywhere(){
	git add .
	git commit -m "$1"
	for remote in $(git remote)
	do
		git push "$remote" "master"
	done
}

function run_ssh_command(){
    ssh webserver bash -s $1 <<'EOF'
	cd $HOME/_path_/project
	source ../bin/activate
	git pull
	python3 manage.py migrate
	sudo supervisorctl restart $1
	exit
EOF
}

find_in_conda_env(){
    conda env list | grep "${@}" >/dev/null 2>/dev/null
}


COMMIT_MESSAGE="${1:-.}"
SERVICES_TO_RESTART="${2:-all}"
TEST_FOLDER="$PWD"/tests
CODE_FOLDER="$PWD"/src

if find_in_conda_env ".*RUN_ENV.*" ; then
   conda init __env__
fi

pytest $TEST_FOLDER -x --disable-pytest-warnings
pytest_result=$?

if [ "$pytest_result" == "0" ]; then
    echo "Pytest OK"
    echo "****************************************************"
    mypy $CODE_FOLDER
    mypy_result=$?
    if [ "$mypy_result" == "0" ]; then
        echo "mypy OK"
        echo "****************************************************"
        flake8 $CODE_FOLDER
        flake8_result=$?
        if [ "$flake8_result" == "0" ]; then
            echo "flake8 OK"
            echo "****************************************************"
            git_save_everywhere "$COMMIT_MESSAGE";
			run_ssh_command "$SERVICES_TO_RESTART";
        elif [ "$flake8_result" == "1" ]; then
            echo "flake8 failed"
        fi
    elif [ "$mypy_result" == "1" ]; then
        echo "mypy failed"
    fi
elif [ "$pytest_result" == "1" ]; then
    echo "pytest failed"
fi