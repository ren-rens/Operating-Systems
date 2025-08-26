#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    if (argc != 4) {
        errx(1, "invalid input: 3 arguments needed!");
    }

    int N = strtol(argv[2], NULL, 10);
    if (N < 0 || N > 255) {
        errx(1, "invalid input: N must be [0, 255]");
    }

    int fd = open(argv[3], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (fd == -1) {
        err(2, "open error: result file");
    }

    int rand = open("/dev/urandom", O_RDONLY);
    if (rand == -1) {
        err(2, "open error: rand file");
    }

    for (int i = 0; i < N; i++) {
        uint16_t S;
        if (read(rand, &S, sizeof(uint16_t)) == -1) {
            err(3, "read error: rand file for S");
        }

        if (S < 1) {
            continue;
        }

        uint8_t bytes[UINT16_MAX];
        if (read(rand, bytes, S) == -1) {
            err(3, "read error: rand file S bytes");
        }

        int pfd[2];
        if (pipe(pfd) == -1) {
            err(4, "pipe error: creating pipe for rand file");
        }

        pid_t pid = fork();
        if (pid == -1) {
            err(5, "fork error");
        }

        if (pid == 0) {
            // child
            close(pfd[1]);

            if (dup2(pfd[0], 0) == -1) {
                err(8, "dup2 error: write point to write of the program");
            }

            int dev_null = open("/dev/null", O_WRONLY|O_TRUNC|O_CREAT, 0644);
            if (dev_null == -1) {
                err(2, "open error: /dev/null file");
            }

            if (dup2(dev_null, 1) == -1) {
                err(8, "dup2 error: write point to /dev/null");
            }

            if (dup2(dev_null, 2) == -1) {
                err(8, "dup2 error: stderr point to /dev/nul");
            }

            close(dev_null);

            if (read(pfd[0], bytes, S) != S) {
                err(3, "write error: in pipe");
            }

            close(pfd[0]);

            execlp(argv[1], argv[1], (char*)NULL);
            err(7, "exec error");
        }

        // parent

        close(pfd[0]);

        if (write(pfd[1], bytes, S) != S) {
            err(6, "read error: from pipr");
        }
        
        close(pfd[1]);

        pid_t st;
        wait(&st);

        if (!WIFEXITED(st)) {
            // child was killed
            close(pfd[0]);

            if (write(fd, bytes, S) != S) {
                err(6, "write error: result file");
            }

            return 42;
        }
        if (WEXITSTATUS(st) != 0) {
            // child exit status is not zero
            close(pfd[0]);
            continue;
        }

        close(pfd[1]);
    }

    close(rand);
    close(fd);

    return 0;
}
