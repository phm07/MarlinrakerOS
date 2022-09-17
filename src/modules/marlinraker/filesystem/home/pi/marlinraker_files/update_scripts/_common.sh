#!/bin/bash

function fetch_latest_release {
    echo $(curl -s "https://api.github.com/repos/$1/$2/releases/latest")
}

function get_remote_version {
    version="$(grep -oPm 1 "\"tag_name\": \"\K[^\"]+")"
    if [ -z $version ]; then
        echo -n "?"
    else
        echo -n $version
    fi
}

function get_current_version {
    if [ -e $1 ]; then
        cat "$1/.version"
    else
        echo -n "?"
    fi
}

function do_update {
    latest_release=$(fetch_latest_release $1 $2)
    version=$(echo $latest_release | get_remote_version)
    download_url=$(echo $latest_release | grep -oPm 1 "\"browser_download_url\": \"\K[^\"]+")

    if [ -z $download_url ]; then
        echo "Cannot fetch download url"
        exit 1
    fi

    mkdir -pv "$3"
    cd "$3"
    rm -rfv *
    wget "$download_url" -O temp.zip 2>&1
    unzip -o temp.zip
    rm -f temp.zip
    rm -f .version
    touch .version
    echo -n $version >> .version
}

function get_info {
    current_version=$(get_current_version $3)
    remote_version=$(echo $(fetch_latest_release $1 $2) | get_remote_version)

    echo -n "{"\
"\"owner\":\"$1\","\
"\"name\":\"$2\","\
"\"version\":\"$current_version\","\
"\"remote_version\":\"$remote_version\","\
"\"configured_type\":\"web\","\
"\"channel\":\"stable\","\
"\"info_tags\":[]"\
"}"
}