#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int in_buff(char symbol, char* buff) {
    int buff_size = strlen(buff);
    for (int i = 0; i < buff_size; i++) {
        if (symbol == buff[i]) {
            return i;
        }
    }
    return -1;
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        errx(1, "invalid input: at least 2 arguments needed");
    }

    char txt[1024];

    if (read(0, txt, 1024) == -1) {
        err(2, "reading error: reading from stdin");
    }

    char result[1024];
    int idx = 0;
    int txt_size = strlen(txt);

    if (strcmp(argv[1], "-d") == 0) {
        for (int i = 0; i < txt_size; i++) {
            if (in_buff(txt[i], argv[2]) != -1) {
                continue;
            }
            result[idx++] = txt[i];
        }
    }
    else if (strcmp(argv[1], "-s") == 0) {
        for (int i = 0; i < txt_size - 1; i++) {
            if (txt[i] == txt[i + 1] && in_buff(txt[i], argv[2]) != -1) {
                continue;
            }
            result[idx++] = txt[i];
        }
    }
    else {
        if (strlen(argv[1]) != strlen(argv[2])) {
            errx(1, "invalid input: set1 and set2 have to have the same lenght");
        }

        for (int i = 0; i < txt_size; i++) {
            int replace_idx = in_buff(txt[i], argv[1]);
            if (replace_idx != -1) {
                result[idx++] = argv[2][replace_idx];
            }
            else {
                result[idx++] = txt[i];
            }
        }
    }

    if (write(1, result, idx) == -1) {
        err(3, "writing error: writing in the stdout");
    }

    return 0;
}
