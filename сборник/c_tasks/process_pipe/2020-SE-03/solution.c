#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

int pfd[8][2];
typedef struct {
    char filename[8];
    uint32_t offset;
    uint32_t len;
} my_file;

my_file files[8];

uint16_t find_xor(int fd, uint32_t offset, uint32_t len) {
    struct stat st;
    if (fstat(fd, &st) == -1) {
        err(3, "fstat error");
    }

    if (st.st_size * sizeof(uint16_t) < offset * sizeof(uint32_t) + len * sizeof(uint32_t)) {
        errx(1, "invalid input: file size is not enough");
    }

    if (lseek(fd, offset, SEEK_SET) == -1) {
        err(8, "lseek error");
    }

    uint16_t xor = 0;
    for (uint32_t i = 0; i < len; i++) {
        uint16_t num;
        if (read(fd, &num, sizeof(num)) == -1) {
            err(7, "read error");
        }

        xor ^= num;
    }

    return xor;
}

void read_current_file(int i) {
    int new_fd = open(files[i].filename, O_RDONLY);
    if (new_fd == -1) {
        err(2, "open error: opening new file");
    }
 
    uint16_t xor = find_xor(new_fd, files[i].offset, files[i].len);
    close(new_fd);

    if (write(pfd[i][1], &xor, sizeof(xor)) == -1) {
        err(6, "write error: in pipe");
    }
    close(pfd[i][1]);
}

void assign_pipes(int count) {
    for (int i = 0; i < count; i++) {

        pid_t pid = fork();
        if (pid == -1) {
            err(4, "fork error");
        }

        if (pid == 0) {
            // child
            for (int j = 0; j < count; j++) {
                if (j == i) {
                    close(pfd[i][0]);
                }
                else {
                    close(pfd[j][0]);
                    close(pfd[j][1]);
                }
            }

            read_current_file(i);
        }
    }

    for (int i = 0; i < count; i++) {
        close(pfd[i][1]);
    }
}

void read_file(char* file) {
    int fd = open(file, O_RDONLY);
    if (fd == -1) {
        err(2, "open error: opening argument");
    }

    struct stat st;
    if (fstat(fd, &st) == -1) {
        err(3, "fstat error");
    }

    int elements_count = st.st_size / sizeof(my_file);
    if (elements_count > 8) {
        errx(1, "invalid input: file has more than 8 elements");
    }

    for (int i = 0; i < elements_count; i++) {
        my_file f;
        if (read(fd, &f, sizeof(f)) == -1) {
            err(7, "read error: from file");
        }
        files[i] = f;
    }

    assign_pipes(elements_count);

    uint16_t xor = 0;
    for (int i = 0; i < elements_count; i++) {
        uint16_t num;
        if (read(pfd[i][0], &num, sizeof(num)) == -1) {
            err(7, "read error: from pipe");
        }

        close(pfd[i][0]);

        xor ^= num;
    }

    printf("%d\n", xor);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        errx(1, "invalid input: one argument needed!");
    }

    for (int i = 0; i < count; i++) {
        if (pipe(pfd[i]) == -1) {
            err(5, "pipe error");
        }
    }

    read_file(argv[1]);

        return 0;
}
