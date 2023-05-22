#!/bin/bash

function check_options() {
    case "$1" in
        -h | --help)
            print_help
            exit 0
            ;;
        -v | --version)
            print_version
            exit 0
            ;;
        -r | --recover)
            do_recover $*
            ;;
        *)
            check_args $*
            create_backup $*
    esac
}

function print_help() {
    echo "Usage: ./backup <source directory> <backup directory>"
}

function print_version() {
    echo "Backup manager v1.0.0"
}

function check_args() {
    if [ "$#" -lt 2 ]; then
        echo "Use -h or --help to see how to work with script"
        exit 1
    fi
}

function do_recover() {
    echo "Recovering..."
}

function create_backup() {
    local source_directory=$1
    local backup_directory=$2
    local backup_name="backup_$(date +'%Y%m%d_%H%M%S').tar"

    if [ ! -d $source_directory ]; then
        echo "Cannot find source directory"
        exit 1
    fi

    if [ ! -d $backup_directory ]; then
        mkdir -p $backup_directory
    fi

    tar -cvf - "$source_directory" | gzip -9c > "$backup_directory/$backup_name".gz

    if [ $? -eq 0 ]; then
        echo "Backup was created successfully!"
    else
        echo "There is something wrong with backup creating"
    fi
}

#Start of the script
check_options $*
