#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

PATH=/bin:/usr/bin

class=$2
assignment=$3

# confirm that the assignment is available

if grep -e "^$assignment@$class$" ~autograder/available-assignments; then
  echo "Copying assignment..."
else
  echo "\nError: Assignment $assignment@$class not found. Please double check your spelling, and yell at Lawton if you did everything right."
  exit 1
fi

# move $1 to ~autograder/submissions-to-grade

chown autograder:bot $1
chmod 600 $1
mv $1 ~autograder/submissions-to-grade

echo "Submitted successfully."