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
    echo "Usage for creating backup: ./backup.sh <source directory> <backup directory>"
    echo "Usage for getting version of manager: ./backup.sh -v/--version"
    echo "Usage for recover backup: ./backup.sh -r/--recover <backup file name> <recover directory>"
}

function print_version() {
    echo "Backup manager v1.0.1"
}

function check_args() {
    if [ "$#" -lt 2 ]; then
        echo "Use -h or --help to see how to work with script"
        exit 1
    fi
}

#Function for recover a backup
function do_recover() {
    local backup_file=$2
    local recover_directory=$3

    #Checking if backup file exists
    if [ ! -f $backup_file ]; then
        echo "This backup file does not exist"
        exit 1
    fi
    
    #Checking if recover directory exists
    if [ ! -d $recover_directory ]; then
        echo "Directory for recovery does not exist. Exiting..."
        exit 1
    fi

    #For encoding
    /usr/bin/openssl des -d -in "$backup_file" -out "$backup_file".tar.gz
    
    #Decompress archive and overwrite files with backup data
    tar -xzf "$backup_file".tar.gz -C "$recover_directory" --overwrite

    if [ $? -eq 0 ]; then
        echo "Backup was recovered succesfully"
    else
        echo "Something went wrong"
    fi
    
    #Deleting archive for security
    rm -rf "$backup_file".tar.gz
}

#Function for backup creating
function create_backup() {
    local source_directory=$1
    local backup_directory=$2
    local backup_name="backup_$(date +'%Y%m%d_%H%M%S').tar"

    #Checking if source directory exists
    if [ ! -d $source_directory ]; then
        echo "Cannot find source directory"
        exit 1
    fi

    #If directory does not exist then create it
    if [ ! -d $backup_directory ]; then
        mkdir -p $backup_directory
    fi

    # Creating backup due to archiving files and compressing it
    tar -cvf - "$source_directory" | gzip -9c > "$backup_directory/$backup_name".gz
    
    #Securing reserve copy
    /usr/bin/openssl des -in "$backup_directory/$backup_name".gz -out "$backup_directory/$backup_name".sec
    
    #Setting +i attr for defence from deleting or updating
    sudo chattr +i "$backup_directory/$backup_name".sec

    #Checking if backup was created
    if [ $? -eq 0 ]; then
        echo "Backup was created successfully!"
    else
        echo "There is something wrong with backup creating"
    fi
    
    #Deleting archive for security
    rm -rf "$backup_directory/$backup_name".gz
}

#Start of the script
check_options $*
