#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <signal.h>
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

int find_index(int agrc, int pid) {
    int idx = -1;
    for (int i = 1; i < argc; i++) {
        if (child_pid[i] == pid) {
            return idx;
        }
    }

    return -1;
}

int main(int argc, char* argv[]) {
    if (argc < 2 || argc > 11) {
        errx(1, "invalid input: arguments must be 1-10");
    }

    for (int i = 1; i < argc; i++) {
        start_process(argv[i], i);
    }

    int count = 0;
    while (count != argc) {
        int st;
        pid = wait(&st);
        if (pid == -1) {
            err(5, "wait error");
        }

        int idx = find_index(argc, pid);

        if (idx == -1) {
            continue;
        }

        if (WIFSIGNALED(st)) {
            // process was killed
            for (int i = 1; i < argc; i++) {
                if (i == idx) {
                    continue;
                }

                if (child_pid[i] > 0) {
                    if (kill(child_pid[i], SIGTERM) == -1) {
                        err(6, "kill error");
                    }
                }
            }

            for (int i = 1; i < argc; i++) {
                if (i == idx) {
                    continue;
                }

                if (child_pid[i] > 0) {
                    waitpid(child_pid[i], NULL, 0);
                }
            }

            exit(idx);
        }

        if (WIFEXITED(st)) {
            // process ended with exit status not null
            // start again
            int code = WEXITSTATUS(st);
            if (code == 0) {
                child_pid[idx] = 0;
                count++;
                continue;
            }
            start_process(argv[idx], idx);
            continue;
        }
    }

        return 0;
}
