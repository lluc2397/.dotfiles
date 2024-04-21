#C# Fuzzy
_fzf() {
	find $@ \( -name "venv" -o -name "*cache*" -o -name ".git" -o -name "build" -o -name "target" \) -prune -o -type f -o -type d -print | fzf
}

#C# Tmux
_new_named_session() {
	if [[ -d $1 || -f $1 ]]; then
		name=$(basename "$1" | tr . _)
		dir_to_go=$(realpath "$1")
	else
		echo "WTF $1"
		return 1
	fi
	tmux_running=$(pgrep tmux)

	if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
		tmux new-session -s "$name" -c "$dir_to_go"
		return 0
	fi

	if ! tmux has-session -t="$name" 2>/dev/null; then
		tmux new-session -ds "$name" -c "$dir_to_go"
	fi

	tmux switch-client -t "$name"

	#tmux attach -t "$name"
}

_fzf_tmux() {
	_new_named_session "$(_fzf $@)"
}

#C# Rust
_new_rust_dir() {
	local folder_name=$1
	shift
	mkdir "$folder_name"
	touch "$folder_name/mod.rs"
	for file_name in "$@"; do
		touch "$folder_name/$file_name.rs"
		echo "pub mod $file_name;" >>"$folder_name/mod.rs"
	done

	echo "Rust project created in $folder_name"
}

#C# Go
mk_go_pack() {
	PCK_NAME=$1
	mkdir "$PCK_NAME"
	touch "$PCK_NAME"/"$PCK_NAME".go
	echo "package $PCK_NAME" >>"$PCK_NAME"/"$PCK_NAME".go
	touch "$PCK_NAME"/"$PCK_NAME"_test.go
	echo "package $PCK_NAME"_test >>"$PCK_NAME"/"$PCK_NAME"_test.go
}

#C# C
_compile_c() {
	source_name="$1"
	final_name="${2:-$source_name}"
	is_shared="${3:-false}"
	if [ "$is_shared" = "true" ]; then
		cc -fPIC -shared -o "$final_name".so "$source_name".c
	else
		cc -o "$final_name" "$source_name".c
	fi
}

#C# C++
_compile_cpp() {
	source_name="$1"
	final_name="${2:-$source_name}"
	g++ -o "$final_name" "$source_name".cpp
}

#C# Cuda
_compile_cuda() {
	source_name="$1"
	final_name="${2:-$source_name}"
	nvcc -o "$final_name" "$source_name".cu -std=c++11
}

#C# Local machine
_cd_and_git_save() {
	cd $1
	_git_save_everywhere "$2"
}

_shutdown_and_save() {
#TODO: fix	$KB todo tool clean
	c_date=$(date +"%Y_%m_%dT%H_%M_%S")
	echo "$c_date"
	commit_msg="${1:-$c_date}"
	_cd_and_git_save "$HOME/Notes" "$commit_msg"
	_cd_and_git_save "$DOTS" "$commit_msg"
	_cd_and_git_save "$HOME/Dev/Exercises/" "$commit_msg"
	shutdown now
}

_list_and_filter() {
	WHERE="${2:-.}"
	ls "$WHERE" | grep -R "$1"
}

_create_new_alias() {
	NAME="$1"
	DO="$2"
	echo "alias $NAME='$DO'" >>'$DOTS/.bash_alias'
	echo "Alias $1 created, refreshing alias"
	rs
	echo "New alias ready"
}

_list_process() {
	NAME="$1"
	ps -C "$NAME" -f
}

_delete_alias() {
	ALIAS="$1"
	sed -i "/\b\($ALIAS\)\b/d" '$DOTS/.bash_alias'
	echo "Alias $NAME deleted, refreshing alias"
	ra
	echo "Alias ready"
}

_create_enter_dir() {
	mkdir -p $1
	cd $1
}

_import_server_invfin_docs() {
	DOC="$1"
	rsync -chavzP --stats --progress "hetzner:~/invfin/invfin/$DOC" .
}

_copy_with_rsync() {
	FROM="$1"
	TO="${2:-.}"
	rsync -chavzP --stats --progress "$FROM" "$TO"
}

_copy_with_tar() {
	FROM="$1"
	TO="${2:-.}"
	tar cf - "$FROM" | tar xvf - -C "$TO"
}

_extract_tgz() {
	FILE="$1"
	TO="${2:-.}"
	tar -xzvf "$FILE" -C "$TO"
}

_count_files_inside() {
	FOLDER="${1:-.}"
	ls "$FOLDER" | wc -l
}

#C# Assembly
_create_executable_from_assemble() {
	nasm -f elf64 "$1.asm" # assemble the program
	ld -s -o "$1" "$1.o"   # link the object file nasm produced into an executable file
}

_link_assembly_to_executable() {
	ld -s -o "$1" "$1.o"
}

#C# Cookiecutter
_create_cookiecutter_project() {
	conda activate myenv
	cookiecutter $1
}

_create_cookiecutter_data() {
	conda activate myenv
	cookiecutter "$HOME"/Dev/cookiecutters/cookiecutter-data-science
	conda deactivate
}

#C# SSH
_create_ssh_key() {
	NAME="$1"
	ssh-keygen -f ~/.ssh/"$NAME" -t ecdsa -b 521
}

_send_ssh_key() {
	NAME="$1"
	USER="$2"
	ssh-copy-id -i ~/.ssh/"$NAME".pub "$USER"
}

_show_ssh_key() {
	NAME="$1"
	cat ~/.ssh/"$NAME"
}

_add_to_agent() {
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/"$1"
}

#C# Venv
_activate_venv() {
	VENV_TYPE="${1:-venv}"
	VENV_NAME="${2:-venv}"
	if [[ "$VENV_TYPE" = "conda" ]]; then
		conda activate $VENV_NAME
    else
		source "$VENV_NAME"/bin/activate
	fi
}

_create_venv() {
	VENV_TYPE="${1:-conda}"
	VENV_NAME="${2:-myenv}"
	if [ "$VENV_TYPE" = "conda" ]; then
		conda create -n $VENV_NAME
	else
		venv "$VENV_NAME"
	fi
}

_create_activate_venv() {
	VENV_TYPE="${1:-venv}"
	VENV_NAME="${2:-venv}"
	_create_venv "$VENV_TYPE" "$VENV_NAME"
	_activate_venv "$VENV_TYPE" "$VENV_NAME"
}

#C# Jupyter
_jupyter_imports() {
	echo "import matplotlib.pyplot as plt" >>"$1"
	echo "import seaborn as sns" >>"$1"
	echo "import pandas as pd" >>"$1"
	echo "import numpy as np" >>"$1"
	echo "import matplotlib" >>"$1"
	echo "import plotly.express as px" >>"$1"
	echo "from pathlib import Path" >>"$1"
}

_new_jupyter_file() {
	FILE_NAME="$1"
	FULL_PATH_FILE="$FILE_NAME".ipynb
	touch "$FULL_PATH_FILE"
	# _jupyter_imports "$FULL_PATH_FILE"
}

#C# Docker
_docker_copy() {
	FROM_FILE="${1:-local.yml}"
	CONTAINER_NAME="${2:-postgres}"
	FOLDER_NAME="${3:-backups}"
	CONTAINER_ID=$(docker compose -f "$FROM_FILE" ps -q "$CONTAINER_NAME")
	echo "$CONTAINER_ID"
	TO_COPY=./"$FOLDER_NAME"/.
	echo "$TO_COPY"
	docker cp "$TO_COPY" "$CONTAINER_ID":/backups
}

#C# Git
_new_tag_push_tag() {
	version="$1"
	git tag -a "$version" -m "Version $version"
	git push origin "$version"
}

_current_git_branch() {
	ref=$(git symbolic-ref HEAD)
	echo ${ref:11}
}

_git_save_dev_new_branch() {
	NOW=$(date +"%Y_%m_%dT%H_%M_%S")
	COMMIT_MESSAGE="${1:-$NOW}"
	CURRENT_BRANCH=$(_current_git_branch)
	BRANCH="${2:-$CURRENT_BRANCH}"
	git add .
	git commit -m "$COMMIT_MESSAGE"
	for remote in $(git remote); do
		--set-upstream "$remote" "$BRANCH"
	done
}

_git_save_everywhere() {
	NOW=$(date +"%Y_%m_%dT%H_%M_%S")
	COMMIT_MESSAGE="${1:-$NOW}"
	CURRENT_BRANCH=$(_current_git_branch)
	BRANCH="${2:-$CURRENT_BRANCH}"
	git add .
	git commit -m "$COMMIT_MESSAGE"
	for remote in $(git remote); do
		git push "$remote" "$BRANCH"
	done
}

_git_regular_save() {
	NOW=$(date +"%Y_%m_%dT%H_%M_%S")
	COMMIT_MESSAGE="${1:-$NOW}"
	CURRENT_BRANCH=$(_current_git_branch)
	REPO="${2:-origin}"
	BRANCH="${3:-$CURRENT_BRANCH}"
	files_to_add="${4:-.}"
	git add "$files_to_add"
	git commit -m "$COMMIT_MESSAGE"
	git push "$REPO" "$BRANCH"
}

_git_custom_key() {
	ESS=$HOME/.ssh/essentialist_bucket
	SSH_KEY="{$1:-$ESS}"
	COMMAND="$2"
	git -c core.sshCommand="ssh -i $SSH_KEY" $COMMAND
}

#C# Django
_delete_all_migrations() {
	find . -path "*/migrations/*.py" -not -path "*/contrib/sites/migrations/*.py" -not -name "__init__.py" -delete
	find . -path "*/migrations/*.pyc" -delete
}

#C# Postgres
_copy_db() {
	DB_NAME="${1:-prod}"
	BACKUP_DIR_PATH="${2:-.}"
	backup_filename="backup_$(date +'%Y_%m_%dT%H_%M_%S').sql.gz"
	pg_dump -d "${DB_NAME}" | gzip >"${BACKUP_DIR_PATH}${backup_filename}"
}

_import_table() {
	DB_NAME="prod"
	DIR_PATH="$PWD"
	TABLES="${1:-"visits_historial_visiteurs" "visiteurs"}"
	EXTENSION="${2:-"sql"}"
	if [ "$EXTENSION" = "csv" ]; then
		for TABLE_NAME in $(echo "$TABLES"); do
			FILE_TO_IMPORT="$DIR_PATH"/"$TABLE_NAME"."$EXTENSION"
			psql --username=lucas --dbname="$DB_NAME" -c "\copy "$TABLE_NAME" from '$FILE_TO_IMPORT' with delimiter as ',' CSV header"
			echo "$TABLE_NAME copied to "$DIR_PATH"/"$TABLE_NAME".csv"
		done
	else
		for TABLE_NAME in $(echo "$TABLES"); do
			FILE_TO_IMPORT="$DIR_PATH"/"$TABLE_NAME"."$EXTENSION"
			psql "$DB_NAME" <""$DIR_PATH"/"$TABLE_NAME".sql"
			echo "$TABLE_NAME copied to "$DIR_PATH"/"$TABLE_NAME".sql"
		done
	fi
}

_export_table() {
	DB_NAME="prod"
	DIR_PATH="$PWD"
	TABLES="${1:-"visits_historial_visiteurs" "visiteurs"}"
	EXTENSION="${2:-"sql"}"
	if [ "$EXTENSION" = "csv" ]; then
		for TABLE_NAME in $(echo "$TABLES"); do
			psql --username=lucas --dbname="$DB_NAME" -c "COPY (SELECT * FROM "$TABLE_NAME") TO stdout DELIMITER ',' CSV HEADER" >""$DIR_PATH"/"$TABLE_NAME".csv"
			echo "$TABLE_NAME copied to "$DIR_PATH"/"$TABLE_NAME".csv"
		done
	else
		for TABLE_NAME in $(echo "$TABLES"); do
			pg_dump -d "${DB_NAME}" -t "$TABLE_NAME" >"${TABLE_NAME}".sql
			echo "$TABLE_NAME copied to "$DIR_PATH"/"$TABLE_NAME".sql"
		done
	fi

}

#C# Server-backup
_download_backup() {
	DB_NAME="${1:-prod}"
	TO="${2:-$HOME/Server/Backups}"
	backup_filename="${DB_NAME}_backup_$(date +'%Y_%m_%dT%H_%M_%S').sql.gz"
	echo "Starting ssh command"
	ssh hetzner "pg_dump "${DB_NAME}" | gzip > /home/lucas/backups/invfin/"${backup_filename}""
	FROM=hetzner:"/home/lucas/backups/invfin/${backup_filename}"
	rsync -chavzP --stats --progress "$FROM" "$TO"
	LOCAL_PATH_INVFIN="$HOME/Projects/invfin/backups/"
	echo Copyin "$TO"/"$backup_filename" into "$LOCAL_PATH_INVFIN""$backup_filename"
	cp "$TO"/"$backup_filename" "$LOCAL_PATH_INVFIN""$backup_filename"
}

_load_last_backup_locally() {
	DB_NAME="${1:-prod}"
	backup_filename="$(ls -Art $PWD/backups/*.sql.gz | tail -n 1)"
	echo "Starting to copying $backup_filename locally"
	dropdb --if-exists -U lucas $DB_NAME
	createdb -U lucas "${DB_NAME}"
	gunzip <"${backup_filename}" | psql "${DB_NAME}"
}

_load_last_backup_docker() {
	echo "Starting docker commands"
	docker compose -f local.yml stop
	docker compose -f local.yml up -d postgres
	CONTAINER_ID=$(docker compose -f local.yml ps -q postgres)
	TO_COPY="$(ls -Art $PWD/backups/*.sql.gz | tail -n 1)"
	docker cp "$TO_COPY" "$CONTAINER_ID":/backups
	echo "$TO_COPY" copied into "$CONTAINER_ID"
	# remove prefix
	backup_filename="${TO_COPY#*$PWD/backups/*}"
	# backup_filename="$(docker compose -f local.yml exec postgres backups | tail -n 1)"
	echo File to backup "$backup_filename"
	docker compose -f local.yml exec postgres restore "$backup_filename"
}

_load_last_backup() {
	TO_USE="${1:-local}"
	DB_NAME="${2:-prod}"
	if [ "$TO_USE" = "local" ]; then
		_load_last_backup_locally $DB_NAME
	elif [ "$TO_USE" = "docker" ]; then
		_load_last_backup_docker
	else
		_load_last_backup_locally $DB_NAME
		_load_last_backup_docker
	fi
}

_download_and_load_backup() {
	TO_USE="${1:-all}"
	DB_NAME="${2:-prod}"
	TO="${3:-$HOME/Server/Backups}"
	backup_filename=$(_download_backup "$DB_NAME" "$TO")
	_load_last_backup "$TO_USE" "$DB_NAME"
}

#C# Django
_restart_migrations() {
	./compose/production/django/reset_migrations.sh
}

_fast_deployment() {
	COMMIT_MESSAGE="${1:-.}"
	APPLY_TO="${2:-all}"
	_git_save_everywhere "$COMMIT_MESSAGE"
	_run_ssh_command_on_remote_server "$APPLY_TO"
}

_run_ssh_command_on_remote_server() {
	ssh hetzner bash -s ${1:-all} <<'EOF'
	cd $HOME/invfin/invfin
	source ../bin/activate
	git pull
	python3 manage.py migrate
	sudo systemctl restart $1
	exit
EOF
}

_restart_migrations_remotely() {
	ssh hetzner bash -s ${1:-all} <<'EOF'
	cd $HOME/invfin/invfin
	source ../bin/activate
	git pull
	python3 manage.py migrate
	./compose/production/django/reset_migrations.sh
	git add .
	git commit -m "restart migrations"
	git push
	sudo systemctl restart $1
	exit
EOF
	git pull prod master
	git push
}
