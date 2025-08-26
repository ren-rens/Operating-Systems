#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

const char DING[] = "DING ";
const char DONG[] = "DONG\n";

int main(int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "invalid input: 2 arguments needed");
    }

    int N = strtol(argv[1], NULL, 10);
    if (N <= 0 || N > 9) {
        errx(1, "invalid input: N must be [1,9]");
    }

    int D = strtol(argv[2], NULL, 10);
    if (D <= 0 || D > 9) {
        errx(1, "invalid input: D must be [1-9]");
    }

    int parent_to_child[2];
    if (pipe(parent_to_child) == -1) {
        err(7, "pipe error: parent to child");
    }

    int child_to_parent[2];
    if (pipe(child_to_parent) == -1) {
        err(7, "pipe error: child to parent");
    }

    char buff;

    pid_t pid = fork();
    if (pid == -1) {
        err(2, "fork error");
    }

     if (pid == 0) {
        // child
        close(parent_to_child[1]);
        close(child_to_parent[0]);

        for (int i = 0; i < N; i++) {
            // DONG
            if (read(parent_to_child[0], &buff, 1) == -1) {
                err(5, "read errror: child waiting for parent");
            }

            if (write(1, DONG, strlen(DONG)) == -1) {
                err(6, "write error: DONG stdout");
            }

            if (write(child_to_parent[1], &buff, 1) == -1) {
                err(6, "write error: child to parent");
            }
        }

        close(parent_to_child[0]);
        close(child_to_parent[1]);

    }

    // parent
    close(child_to_parent[1]);
    close(parent_to_child[0]);

    for (int i = 0; i < N; i++) {
        // DING
        if (i == 0) {
            if (write(1, DING, strlen(DING)) == -1) {
                err(6, "write error: DONG stdout");
            }

            if (write(parent_to_child[1], &buff, 1) == -1) {
                err(6, "write error: child to parent");
            }
            continue;
        }

        if (read(child_to_parent[0], &buff, 1) == -1) {
            err(5, "read error: child to parent pipe");
        }

        sleep(D);
 
        if (write(1, DING, strlen(DING)) == -1) {
            err(6, "write error: stdout DING");
        }

        if (write(parent_to_child[1], &buff, 1) == -1) {
            err(6, "write error: parent to child pipe");
        }
    }

    close(child_to_parent[0]);
    close(parent_to_child[1]);


        return 0;
}
