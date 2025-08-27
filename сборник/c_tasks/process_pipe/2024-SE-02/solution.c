#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

int child_pid[11];

void start_process(char* arg, int idx) {
    pid_t pid = fork();
    if (pid == -1) {
        err(3, "fork error");
    }

    if (pid == 0) {
        // child process

        execlp(arg, arg, (char *)NULL);
        err(4, "exec error");
    }

    child_pid[idx] = pid;
}

int main(int argc, char* argv[]) {
    if (argc < 2 || argc > 11) {
        errx(1, "invalid input: arguments must be 1-10");
    }

    int pfd[2][10];
    for (int i = 1; i < argc; i++) {
        if (pipe(pfd[i]) == -1) {
            err(2, "pipe error");
        }
        start_process(argv[i], i);
    }
    int count = 0;
    int idx = 1;
    while (count != argc) {
        int st;
        if (waitpid(child_pid[idx], &st, 0) == -1) {
            err(5, "wait error");
        }
        if (!WIFEXITED(st)) {
            // process was killed
            for (int i = 1; i < argc; i++) {
                if (child_pid[i] == 0) {
                    continue;
                }

                if (kill(child_pid[i], SIGTERM) == 0) {
                    err(6, "kill error");
                }
            }

            exit(idx);
        }

        if (WEXITSTATUS(st) != 0) {
            // process ended with exit status not null
            // start again

            start_process(argv[idx], idx);
        }

        child_pid[idx] = 0;
        count++;
        idx++;
    }

        return 0;
}
