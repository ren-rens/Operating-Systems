#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

typedef struct {
    uint16_t offset;
    uint8_t original_byte;
    uint8_t new_byte;
} replacements_t;

void fill_patch(int f1, int size1, int f2, int patch) {
    uint8_t original_byte;

    for (int i = 0; i < size1; i++) {
        if (read(f1, &original_byte, sizeof(uint8_t)) == -1) {
            err(4, "read error: file1");
        }

        uint8_t curr_byte;
        if (read(f2, &curr_byte, sizeof(uint8_t)) == -1) {
            err(4, "read error: file2");
        }

        if (curr_byte != original_byte) {
            replacements_t r;

            r.original_byte = original_byte;
            r.new_byte = curr_byte;
            r.offset = (uint16_t)i;

            if (write(patch, &r, sizeof(r)) == -1) {
                err(6, "write error: patch");
            }
        }
    }
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        errx(1, "invalid input: 3 arguments needed!");
    }

    int f1 = open(argv[1], O_RDONLY);
    if (f1 == -1) {
        err(2, "open error: file1");
    }

    int f2 = open(argv[2], O_RDONLY);
    if (f2 == -1) {
        err(2, "open error: file2");
    }

    struct stat st1, st2;
    if (fstat(f1, &st1) == -1) {
        err(3, "fstat error: file1");
    }

    if (fstat(f2, &st2) == -1) {
        err(3, "fstat error: file2");
    }

    if (st1.st_size != st2.st_size) {
        errx(1, "invalid input: files 1 and 2 have different sizes");
    }

    int patch = open(argv[3], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (patch == -1) {
        err(2, "open error: file patch");
    }

    fill_patch(f1, st1.st_size, f2, patch);

    close(f1);
    close(f2);
    close(patch);

    return 0;
}
