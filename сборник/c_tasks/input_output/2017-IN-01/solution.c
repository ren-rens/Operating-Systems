#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>

typedef struct {
    uint16_t offset;
    uint8_t len;
    uint8_t saved;
} string_t;

off_t get_size(int dat1) {
    struct stat st;
    if (fstat(dat1, &st) == -1) {
        err(3, "fstat error: f1.dat");
    }
    return st.st_size;
}

void solve(int dat1, int idx1, int dat2, int idx2) {
    string_t s;
    int read_bytes;
    uint16_t offset = 0;
    off_t dat1_size = get_size(dat1);

    while ((read_bytes = read(idx1, &s, sizeof(s))) > 0) {
        if (dat1_size < s.offset + s.len) {
            errx(1, "input error: f1.dat size");
        }

        if (lseek(dat1, s.offset, SEEK_SET) == -1) {
            err(4, "lseek error: f1.dat");
        }

        uint8_t string[1024];
        if (s.len > sizeof(string)) {
            errx(1, "input error: string too long");
        }

        if (read(dat1, string, s.len) != s.len) {
            err(5, "reading error: f1.dat");
        }

        if (string[0] >= 'A' && string[0] <= 'Z') {
            if (write(dat2, string, s.len) != s.len) {
                err(6, "writing error: f2.dat");
            }

            s.offset = offset;
            offset += s.len;

            if (write(idx2, &s, sizeof(s)) != sizeof(s)) {
                err(6, "writing error: f2.idx");
            }
        }
    }

    if (read_bytes == -1) {
        err(5, "reading error: f1.idx");
    }
}

int main(int argc, char* argv[]) {
    if (argc != 5) {
        errx(1, "input error: 4 arguments needed!");
    }

    int dat1=open(argv[1], O_RDONLY);
    if (dat1 == -1) {
        err(2, "open file error: f1.dat");
    }

    int idx1=open(argv[2], O_RDONLY);
    if (idx1 == -1) {
        err(2, "open file error: f1.idx");
    }

    struct stat st;
    if (fstat(idx1, &st) == -1) {
        err(3, "fstat error: f1.idx");
    }

    if (st.st_size % sizeof(string_t) != 0) {
        errx(1, "invalid input: f1.idx file size");
    }

    int dat2=open(argv[3], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (dat2 == -1) {
        err(2, "open file error: f2.dat");
    }

    int idx2=open(argv[4], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (idx2 == -1) {
        err(2, "open file error: f2.idx");
    }

    solve(dat1, idx1, dat2, idx2);

    close(dat1);
    close(idx1);
    close(dat2);
    close(idx2);

    return 0;
}
