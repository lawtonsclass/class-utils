#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

user=$1
user_home_folder=$(eval echo ~$user)

mkdir -p $user_home_folder/.autograder