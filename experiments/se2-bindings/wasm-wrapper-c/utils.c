#include "utils.h"

#include <unistd.h>

#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

#define PATH_MAX 4096

void print_current_dir()
{
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof(cwd)) != NULL)
        printf("\tutils.c | Current working dir: %s\n", cwd);
}

void list_current_dir()
{
#define _XOPEN_SOURCE 700

    DIR *dp;
    struct dirent *ep;
    dp = opendir("./");
    if (dp != NULL)
    {
        while ((ep = readdir(dp)) != NULL)
            printf("\tutils.c |  %s\n", ep->d_name);

        printf("\n\n");
        (void)closedir(dp);
    }
    else
    {
        perror("\tutils.c | Couldn't open the current directory");
    }
}
