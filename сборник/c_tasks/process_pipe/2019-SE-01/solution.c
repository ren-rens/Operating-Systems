#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

int main(int argc, char* argv[]) {
    if (argc < 3) {
        errx(1, "invalid input: 3 arguments needed!");
    }

    int lasting = strtol(argv[1], NULL, 10);
    if (lasting < 0 || lasting > 9) {
        errx(1, "invalid input: lasting must be in range [1,9] seconds");
    }

    char* arguments[argc - 1];
    for (int i = 2; i < argc; i++) {
        arguments[i - 2] = argv[i];
    }

    arguments[argc - 2] = NULL;

    int fd = open("run.log", O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (fd == -1) {
        err(4, "open error");
    }

    int current_status = 0;
    int previous_status = 0;
    time_t start = 0;
    time_t end = 0;
    while (1) {
        start = time(NULL);

        pid_t pid = fork();
        if (pid == -1) {
            err(2, "fork error");
        }

        if (pid == 0) {
            // child


            execvp(argv[2], arguments);
            err(3, "exec error");
       }

        // parent
        int st;
        if (wait(&st) == -1) {
            err(6, "wait error");
        }

        end = time(NULL);

        if (!WIFEXITED(st)) {
            // process was killed
            current_status = 129;
        }
        else {
            current_status = WEXITSTATUS(st);
        }


        char buff[256];
        int len = snprintf(buff, sizeof(buff), "%ld %ld %d\n", start, end, curre
nt_status);
        if (write(fd, buff, len) == -1) {
            err(5, "write error");
        }

        if (current_status != 0 && previous_status != 0 && (end - start) < lasti
ng) {
            break;
        }

        previous_status = current_status;
    }

    close(fd);

    return 0;
}
