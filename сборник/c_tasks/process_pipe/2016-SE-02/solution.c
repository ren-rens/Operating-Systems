#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

const char promt[] = "> ";

int main(void) {
    while (1) {
        if (write(1, promt, strlen(promt)) == -1) {
            err(1, "write error: promt");
        }

        char command[1024];
        int idx = 0;
        char buff;
        int read_bytes;
        while ((read_bytes = read(0, &buff, sizeof(char))) > 0) {
            if (buff == ' ' || buff == '\n') {
                break;
            }
            command[idx++] = buff;
        }

        if (read_bytes == -1) {
            err(2, "read error: command");
        }

        command[idx] = '\0';

        if (strcmp(command, "exit") == 0) {
            break;
        }

        int pid = fork();
        if (pid == -1) {
            err(3, "fork error");
        }

        if (pid == 0) {
            // child
            execlp(command, command, (char*)NULL);
            err(4, "exec error");
        }

        // parent
        wait(NULL);
    }

    return 0;
}
