#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <stdio.h>
#include <string.h>

const int MAX_CMD_LEN = 4;
const int MAX_ARG_LEN = 4;

void execute_command(const char* command, const char* arg1, const char* arg2) {
    int pid = fork();
    if (pid == -1) {
        err(3, "fork error");
    }

    if (pid == 0) {
        // child
        if (arg1[0] == '\0' && arg2[0] == '\0') {
            execlp(command, command, (char*)NULL);
        }
        else if (arg2[0] == '\0') {
            execlp(command, command, arg1, (char*)NULL);
        }
        else {
            execlp(command, command, arg1, arg2, (char*)NULL);
        }

        err(4, "exec error");
    }

    // parent
    if (wait(NULL) == -1) {
        err(5, "wait error");
    }
}

int main(int argc, char* argv[]) {
    char command[] = "echo";

    if (argc == 2) {
        if (strlen(argv[1]) > MAX_CMD_LEN) {
            errx(1, "invalid input: max len for a command is 4 symbols");
        }
        strcpy(command, argv[1]);
    }

    char arguments[2][MAX_ARG_LEN + 1];
    arguments[0][0] = '\0';
    arguments[1][0] = '\0';

    char argument[MAX_ARG_LEN + 1];
    int i = 0;     // current argument index
    int j = 0;     // count of arguments
    char buff;
    ssize_t read_bytes;

    while ((read_bytes = read(0, &buff, 1)) > 0) {
        if (buff == ' ' || buff == '\n') {
            if (i > 0) {
                argument[i] = '\0';
                if (strlen(argument) > MAX_ARG_LEN) {
                    errx(1, "invalid input: each argument must be at most 4 symbols long");
                }

                strcpy(arguments[j++], argument);
                i = 0;
            }

            if (j == 2) {
                execute_command(command, arguments[0], arguments[1]);

                j = 0;
                arguments[0][0] = '\0';
                arguments[1][0] = '\0';
            }
        }
        else {
            if (i >= MAX_ARG_LEN) {
                errx(1, "invalid input: each argument must be at most 4 symbols long");
            }
            argument[i++] = buff;
        }
    }

    if (read_bytes == -1) {
        err(2, "read error");
    }

    if (i > 0) { // последен аргумент преди EOF
        argument[i] = '\0';
        if (strlen(argument) > MAX_ARG_LEN) {
            errx(1, "invalid input: each argument must be at most 4 symbols long");
        }
        strcpy(arguments[j++], argument);
    }

    if (j > 0) {
        execute_command(command, arguments[0], (j == 2) ? arguments[1] : "");
    }

    return 0;
}
