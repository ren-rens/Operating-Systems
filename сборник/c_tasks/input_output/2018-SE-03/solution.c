#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define MAX_SIZE 1024
char buff[MAX_SIZE];
int N;
int M;
char delimiter;

void input(char* flag, char* argv[]) {
    if (strcmp(flag, "-d") == 0) {
        delimiter = argv[2][0];
        if (strcmp(argv[3], "-f") != 0) {
            errx(1, "invalid input: wrong input for -d flag");
        }

        if (strlen(argv[4]) == 1) {
            N = atoi(argv[4]);
            M = N;

            if (N < 0 || N > 10) {
                errx(1, "invalid input: N must be [1,9]");
            }
        }
        else if (strlen(argv[4]) == 3 && argv[4][1] == '-') {
            N = atoi(argv[4]);
            M = atoi(argv[4] + 2);
            if (M < 0 || M > 9 || N < 0 || N > 9) {
                errx(1, "invalid input: Must be [1,9]");
            }
        }
    }
    else if (strcmp(flag, "-c") == 0) {
        if (strlen(argv[2]) == 1) {
            N = atoi(argv[2]);
            M = N;
            if (N < 0 || N > 9) {
                errx(1, "invalid input: N must be [1,9]");
            }
        }
        else if (strlen(argv[2]) == 3 && argv[2][2] == '-') {
            N = atoi(argv[2]);
            M = atoi(argv[2] + 2);
            if (N < 0 || N > 9 || M < 0 || M > 9) {
                errx(1, "invalid input: N must be [1,9]");
            }
        }
    }
    else {
        errx(1, "input error: must be a -d -c flag");
    }

    if (M < N) {
        errx(1, "invalid input: M must be bigger than N");
    }
}

void input_buff(void) {
    for (int i = 0; i < MAX_SIZE; i++) {
        buff[i] = '\0';
    }
}

void delimiter_print(void) {
    int field_count = 0;
    for (int i = 0; i < MAX_SIZE; i++) {
        if (buff[i] == '\0') {
            break;
        }

        if (buff[i] == delimiter) {
            field_count++;
            continue;
        }

        if (field_count >= N && field_count <= M) {
            // print
            if (write(1, &buff[i], sizeof(char)) == -1) {
                err(2, "write error");
            }
        }
    }

    char new_line = '\n';
    if (write(1, &new_line, sizeof(char)) == -1) {
        err(2, "write error");
    }
}

void symbol_print(void) {
    for (int i = N; i <= M; i++) {
        if (buff[i] == '\0') {
            break;
        }

        if (write(1, &buff[i], sizeof(char)) == -1) {
            err(2, "write error");
        }
    }

    char new_line = '\n';
    if (write(1, &new_line, sizeof(char)) == -1) {
        err(2, "write error");
    }
}

int main(int argc, char* argv[]) {
    if (argc < 3)  {
        errx(1, "input error: too few arguments");
    }

    char* flag = argv[1];
    if (strcmp(flag, "-d") != 0 && strcmp(flag, "-c") != 0) {
        errx(1, "invalid input: flags must be -d or -c");
    }

    input(flag, argv);
    input_buff();

    char byte;
    int idx = 0;
    int read_bytes;
    while ((read_bytes = read(0, &byte, sizeof(char))) > 0) {
        if (byte == '\n') {
            idx = 0;

            if (strcmp(flag, "-d") == 0) {
                delimiter_print();
            }
            else {
                symbol_print();
            }

            input_buff();
        }

        buff[idx++] = byte;
    }

    if (read_bytes == -1) {
        err(3, "read error");
    }

    return 0;
}
