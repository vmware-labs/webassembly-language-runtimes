#include "utils.h"


#include <dirent.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#define PATH_MAX 4096

void print_current_dir()
{
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof(cwd)) != NULL)
        LOG_MSG(__FILENAME__, "Current working dir: %s", cwd);
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
            LOG_MSG(__FILENAME__, "  - %s", ep->d_name);

        LOG_MSG(__FILENAME__, "\n");
        (void)closedir(dp);
    }
    else
    {
        perror("utils.c | E | Couldn't open the current directory");
    }
}
