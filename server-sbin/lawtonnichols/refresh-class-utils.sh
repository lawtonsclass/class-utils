#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

cd /class-utils
git pull
chmod -R 700 /class-utils
chown -R lawtonnichols:teacher /class-utils

# put the proper default permissions on everything
chmod -R 700 server-sbin
chmod -R 755 server-bin
chown -R lawtonnichols:teacher server-sbin/lawtonnichols/*
chown -R autograder:bot server-sbin/autograder/*

# put special permissions on /usr/local/bin files
gcc server-bin/refresh-starter-code.c -o server-bin/refresh-starter-code
chown root server-bin/refresh-starter-code

gcc server-bin/finish-turnin.c -o server-bin/finish-turnin
chown root server-bin/finish-turnin

# put all the files in their proper places
cp server-bin/* /usr/local/bin
mkdir -p ~lawtonnichols/bin
mkdir -p ~autograder/bin
cp server-sbin/autograder/* ~autograder/bin
cp server-sbin/lawtonnichols/* ~lawtonnichols/bin
chown -R autograder:bot ~autograder/bin
chown -R lawtonnichols:teacher ~lawtonnichols/bin
chmod -R 700 ~autograder/bin ~lawtonnichols/bin

# setuid for /usr/local/bin files because copying destroys them
chmod u+s /usr/local/bin/refresh-starter-code
chmod u+s /usr/local/bin/finish-turnin

# put special permissions and setuid on autograder's and lawtonnichols's files
# chmod u+s ~autograder/bin/autograde
# chmod u+s ~autograder/bin/autograde-one-submission

chown root:bot ~autograder/bin/make-autograder-folder-for-user
chmod 750 ~autograder/bin/make-autograder-folder-for-user
chmod u+s ~autograder/bin/make-autograder-folder-for-user

gcc ~lawtonnichols/bin/refresh-class-utils.c -o ~lawtonnichols/bin/refresh-class-utils
chown root:teacher ~lawtonnichols/bin/refresh-class-utils
chmod 750 ~lawtonnichols/bin/refresh-class-utils
chmod u+s ~lawtonnichols/bin/refresh-class-utils

# remove all the unnecessary c files
rm -f /usr/local/bin/*.c ~lawtonnichols/bin/*.c ~autograder/bin/*.c

# change the owner back so that nobody can see this stuff
chmod -R 700 /class-utils
chown -R lawtonnichols:teacher /class-utils