#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

cd ~lawt/class-utils
git checkout -- .
git clean -f
git pull
chmod -R 700 ~lawt/class-utils
chown -R lawt:teacher ~lawt/class-utils

# put the proper default permissions on everything
chmod -R 700 server-sbin
chmod -R 755 server-bin
chown -R lawt:teacher server-sbin/lawt/*
chown -R autograder:bot server-sbin/autograder/*

# put special permissions on /usr/local/bin files
gcc server-bin/refresh-starter-code.c -o server-bin/refresh-starter-code
chown root server-bin/refresh-starter-code

gcc server-bin/finish-turnin.c -o server-bin/finish-turnin
chown root server-bin/finish-turnin

# put all the files in their proper places
cp server-bin/* /usr/local/bin
mkdir -p ~lawt/bin
mkdir -p ~autograder/bin
cp server-sbin/autograder/* ~autograder/bin
cp server-sbin/lawt/* ~lawt/bin
chown -R autograder:bot ~autograder/bin
chown -R lawt:teacher ~lawt/bin
chmod -R 700 ~autograder/bin ~lawt/bin

# setuid for /usr/local/bin files because copying destroys them
chmod u+s /usr/local/bin/refresh-starter-code
chmod u+s /usr/local/bin/finish-turnin

# put special permissions and setuid on autograder's and lawt's files
# chmod u+s ~autograder/bin/autograde
# chmod u+s ~autograder/bin/autograde-one-submission

gcc ~autograder/bin/make-autograder-folder-for-user.c -o ~autograder/bin/make-autograder-folder-for-user
chown root:bot ~autograder/bin/make-autograder-folder-for-user
chmod 750 ~autograder/bin/make-autograder-folder-for-user
chmod u+s ~autograder/bin/make-autograder-folder-for-user

gcc ~autograder/bin/autograde-one-submission.c -o ~autograder/bin/autograde-one-submission
chown root:bot ~autograder/bin/autograde-one-submission
chmod 750 ~autograder/bin/autograde-one-submission
chmod u+s ~autograder/bin/autograde-one-submission

gcc ~lawt/bin/refresh-class-utils.c -o ~lawt/bin/refresh-class-utils
chown root:teacher ~lawt/bin/refresh-class-utils
chmod 750 ~lawt/bin/refresh-class-utils
chmod u+s ~lawt/bin/refresh-class-utils

chown root:teacher ~lawt/bin/add-student
chmod 750 ~lawt/bin/add-student
chmod u+s ~lawt/bin/add-student

# remove all the unnecessary c files
rm -f /usr/local/bin/*.c ~lawt/bin/*.c ~autograder/bin/*.c

# include the graphics library
cp include/graphics /usr/local/include
chown root:teacher /usr/local/include/graphics
chmod 664 /usr/local/include/graphics

# change the owner back so that nobody can see this stuff
chmod -R 700 ~lawt/class-utils
chown -R root:root ~lawt/class-utils
