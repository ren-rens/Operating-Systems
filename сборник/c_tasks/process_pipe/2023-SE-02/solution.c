#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

const char* str = "found it!";

int main(int argc, char* argv[]) {
    if (argc < 2) {
        errx(26, "input error: to few arguments");
    }

    int pfd[2];
    if (pipe(pfd) == -1) {
        err(26, "pipe error");
    }

    for (int i = 1; i < argc; i++) {
        // starting process
        pid_t pid = fork();
        if (pid == -1) {
            err(26, "fork error");
        }

        if (pid == 0) {
            // child
            close(pfd[0]);

            if (dup2(pfd[1], 1) == -1) {
                err(26, "dup2 error");
            }

            close(pfd[1]);

            execlp(argv[i], argv[i], (char*)NULL);
            err(26, "exec error");
        }
    }

    // parent

    close(pfd[1]);
   
    char buff;
    size_t curr = 0;

    while (read(pfd[0], &buff, 1) == 1) {
        if (buff == str[curr]) {
            curr++;
        }
        else {
            curr = 0;
        }

        if (curr == strlen(str)) {
            close(pfd[0]);
            if (kill(0, SIGTERM) == -1) {
                err(26, "kill error");
            }

             exit(0);
        }
    }

    close(pfd[0]);

    exit(1);
}
