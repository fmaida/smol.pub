#!/bin/bash

host=https://smol.pub

validate_post() {
    readarray -t arr < $1
    if [[ "$(echo ${arr[0]} | cut -b-2)" != "# " ]] || [[ "${arr[1]}" != "" ]]
    then
	echo "First line needs to start with a title (# Hello World)"
	echo "Second line needs to be left blank."
    fi
}

validate_post $1

if [ $# -eq 1 ]
then
    status=$(curl -s -o /dev/null -w "%{http_code}"\
	 --form-string title="$(head -1 $1 | cut -b3-)"\
	 --form-string slug="$1"\
	 --form-string content="$(tail -n +3 $1)"\
	 -b smolpub="$(cat ~/.config/.smolpub)"\
	 $host/posts/save)

    if [ $status -ne 302 ]
    then
	curl --form-string title="$(head -1 $1 | cut -b3-)"\
	     --form-string slug="$1"\
	     --form-string content="$(tail -n +3 $1)"\
	     -b smolpub="$(cat ~/.config/.smolpub)"\
	     $host/posts/$1/update
    fi
fi
