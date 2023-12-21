#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

PATH=/bin:/usr/bin

class=$2
assignment=$3
user=$4

# confirm that the assignment is available

if grep -e "^$assignment@$class$" ~autograder/available-assignments; then
  echo "Copying assignment..."
else
  echo -e "\nError: Assignment $assignment@$class not found. Please double check your spelling, and yell at Lawton if you did everything right."
  exit 1
fi

# move $1 to ~autograder/submissions-to-grade

chown autograder:bot $1
chmod 600 $1
mv $1 ~autograder/submissions-to-grade

echo -e "\nSubmitted successfully."

~autograder/bin/make-autograder-folder-for-user $user

echo "" > /home/"$user"/.autograder/log
chown "$user":student /home/"$user"/.autograder/log
chmod 400 /home/"$user"/.autograder/log

echo -e "\nWaiting for the autograder to become available." > /home/"$user"/.autograder/log
echo -e "(Press Ctrl-C to close this submission window at any time--\n  your submission will still be graded.)" > /home/"$user"/.autograder/log
