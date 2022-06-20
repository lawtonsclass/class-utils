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

zip_file_basename=$(basename "$1")

# figure out which assignment to grade based on the filename
submission_date=$(stat -c '%Y' "$1")
class=$(get-assignment-class "$zip_file_basename")
assignment=$(get-assignment-assignment "$zip_file_basename")
user=$(get-assignment-user "$zip_file_basename")
resultfilename=$class-$assignment-$user.json
user_home_folder=$(eval echo ~$user)

echo $@
echo $submission_date
echo $class
echo $assignment
echo $user
echo $resultfilename
echo $user_home_folder

echo "Submission grading started." >> "$user_home_folder"/.autograder/log

# create a new docker container called "autograder_ephemeral"
docker container create -t --name autograder_ephemeral autograder_template
docker start autograder_ephemeral
docker update --cpus="1.0" autograder_ephemeral

# copy the correct autograder into the docker container
docker cp ~autograder/autograders/$class/$assignment autograder_ephemeral:/root

# now the file exists in the /root/$assignment folder

# copy the autograder library into the docker container (unnecessary)
# docker cp ~autograder/bin/autograderlib.py autograder_ephemeral:~/$class/$assignment

# copy the code extracted into ~/.autogradertmp into the docker container
docker cp ~autograder/.autogradertmp autograder_ephemeral:/root/$assignment
docker exec autograder_ephemeral mv /root/$assignment/.autogradertmp /root/$assignment/submission

# run the autograder inside the docker container
docker exec autograder_ephemeral python3 /root/$assignment/autograder.py $class $assignment $user $submission_date

# extract the results.json file from the docker container into a file called $resultfilename
docker cp autograder_ephemeral:/root/$assignment/$resultfilename ~autograder

# delete the docker container
docker stop autograder_ephemeral
docker rm --force autograder_ephemeral

# move the results file into the user's home directory, and give them read access
/home/autograder/bin/make-autograder-folder-for-user $user
if [ -f $user_home_folder/.autograder/$resultfilename ]; then
  # if the user has submitted this assignment before
  mv $user_home_folder/.autograder/$resultfilename $user_home_folder/.autograder/previous_submissions/$(date "+%Y%m%d%H%m")-$resultfilename
fi
chmod 400 ~autograder/$resultfilename
# TODO: save only the last 5 submissions
cp ~autograder/$resultfilename ~autograder/grades/
mv ~autograder/$resultfilename $user_home_folder/.autograder/
chown $user $user_home_folder/.autograder/$resultfilename
chown autograder:bot ~autograder/grades/$resultfilename

if [ -f ~autograder/$resultfilename ]; then
  echo "$resultfilename didn't get moved! Something went wrong!"
  rm -f ~autograder/$resultfilename
fi

echo "Submission grading finished. You are now able to use \"view-grades\" and see your score on the terminal." >> "$user_home_folder"/.autograder/log

echo "Uploading grade to the class website." >> "$user_home_folder"/.autograder/log

# upload grade to class website in user folder
chmod u+w ~autograder/grades/$resultfilename
ssh -o ConnectTimeout=5 -i ~autograder/.ssh/autograder_key lawt@www.lawtonsclass.com "mkdir -p /home/lawt/class_website/grades/$user" || \
  echo "Error connecting to the class website. Please tell Lawton about this." >> "$user_home_folder"/.autograder/log
scp -o ConnectTimeout=5 -i ~autograder/.ssh/autograder_key ~autograder/grades/$resultfilename lawt@www.lawtonsclass.com:/home/lawt/class_website/grades/$user || \
  echo "Error uploading grade. Please tell Lawton about this." >> "$user_home_folder"/.autograder/log
chmod u-w ~autograder/grades/$resultfilename

echo "Done." >> "$user_home_folder"/.autograder/log
echo "Autograding is complete. Please press Ctrl-C to close this submission program." >> "$user_home_folder"/.autograder/log

