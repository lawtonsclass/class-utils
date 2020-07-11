#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>

int main(int argc, char* argv[])
{
    char *envp[] =
    {
        "PATH=/bin:/usr/bin",
        0
    };
    setuid(0);
    execve("/home/autograder/bin/autograde-one-submission.sh", argv, envp);
    fprintf(stderr, "Couldn't run program! This shouldn't happen--please yell at Lawton.\n");
    return 1;
}