#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

function get-assignment-class {
local result=$(python3 - <<END
print("$1".split('.')[0].split('-')[0])
END
)
  echo $result
}

function get-assignment-assignment {
local result=$(python3 - <<END
print("$1".split('.')[0].split('-')[1])
END
)
  echo $result
}

function get-assignment-user {
local result=$(python3 - <<END
print("$1".split('.')[0].split('-')[2])
END
)
  echo $result
}

set -v

# get the submission zip file, and unzip it
rm -rf ~autograder/.autogradertmp
mkdir ~autograder/.autogradertmp
unzip "$1" -d ~autograder/.autogradertmp

# figure out which assignment to grade based on the filename
submission_date=$(stat -c '%Y' "$1")
class=$(get-assignment-class "$1")
assignment=$(get-assignment-assignment "$1")
user=$(get-assignment-user "$1")
resultfilename=$class-$assignment-$user.json
user_home_folder=$(eval echo ~$user)

echo $@
echo $submission_date
echo $class
echo $assignment
echo $user
echo $resultfilename
echo $user_home_folder

# create a new docker container called "autograder_ephemeral"
docker container create --name autograder_ephemeral autograder_template
docker start autograder_ephemeral

# copy the correct autograder into the docker container
docker cp ~autograder/autograders/$class/$assignment autograder_ephemeral:~

# copy the autograder library into the docker container (unnecessary)
# docker cp ~autograder/bin/autograderlib.py autograder_ephemeral:~/$class/$assignment

# copy the code extracted into ~/.autogradertmp into the docker container
docker cp ~autograder/.autogradertmp autograder_ephemeral:/root/$class/$assignment
docker exec autograder_ephemeral mv /root/$class/$assignment/.autogradertmp /root/$class/$assignment/submission

# run the autograder inside the docker container
docker exec autograder_ephemeral python3 /root/$class/$assignment/autograder.py $class $assignment $user $submission_date

# extract the results.json file from the docker container into a file called $resultfilename
docker cp autograder_ephemeral:/root/$class/$assignment/$resultfilename ~autograder

# delete the docker container
docker stop autograder_ephemeral
docker rm --force autograder_ephemeral

# move the results file into the user's home directory, and give them read access
if [ -f $user_home_folder/.autograder/$resultfilename ]; then
  # if the user has submitted this assignment before
  mv $user_home_folder/.autograder/$resultfilename $user_home_folder/.autograder/previous_submissions/$(date "+%Y%m%d%H%m")$resultfilename
fi
make-autograder-folder-for-user $user
chmod 400 $resultfilename
# TODO: save only the last 5 submissions
mv ~autograder/$resultfilename $user_home_folder/.autograder
chown $user $user_home_folder/.autograder/$resultfilename