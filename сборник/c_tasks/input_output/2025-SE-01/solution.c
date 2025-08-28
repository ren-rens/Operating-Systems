#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

void write_in_temp(int temp, char* role, char* words, int N, uint64_t time) {
    words[N] = '\0'; // за безопасност
    dprintf(temp, "%llu %s: %s\n",
            (unsigned long long)time, role, words);
}


void copy_in_temp(int temp, int fd) {
    // read from file

    uint8_t N;
    uint64_t id;
    char role[256];
    char words[256];
    int read_bytes;

    while ((read_bytes = read(fd, &id, sizeof(id))) > 0) {
        if (id == 133742) {
            // header -> has role
            char buff[256];
            if (read(fd, &N, sizeof(N)) == -1) {
                err(5, "read error: N in header");
            }

            for (int i = 0; i < N; i++) {
                if (read(fd, &buff[i], sizeof(char)) == -1) {
                    err(5, "read error: role in header");
                }
            }

            buff[N] = '\0';
            strcpy(role, buff);
            continue;
        }

        // not in header -> words to write
        if (read(fd, &N, sizeof(N)) == -1) {

 err(5, "read error: N in header");
        }

        for (int i = 0; i < N; i++) {
            if (read(fd, &words[i], sizeof(char)) == -1) {
                err(5, "read error: role in header");
            }
        }

        write_in_temp(temp, role, words, N, id);
    }

    if (read_bytes == -1) {
        err(5, "read error: id");
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2 || argc > 21) {
        errx(1, "invalid input arguments may be [1,20]");
    }

    int temp = open("tempfile.txt", O_RDWR|O_TRUNC|O_CREAT, 0644);
    for (int i = 1; i < argc; i++) {
        int fd = open(argv[i], O_RDONLY);
        if (fd == -1) {
            err(2, "open file error: argument file");
        }

        struct stat st;
        if (fstat(fd, &st) == -1) {
            err(3, "fstat error");
        }

        copy_in_temp(temp, fd);

        close(fd);
    }

    // sort temp file

    close(temp);

    pid_t pid = fork();
    if (pid == -1) {
        err(6, "fork error");
    }


    if (pid == 0) {
        // child
        execlp("sort", "sort", "-n", "-k1,1", "tempfile.txt", (char*)NULL);
        err(7, "exec error");
    }

    wait(NULL);

        return 0;
}
