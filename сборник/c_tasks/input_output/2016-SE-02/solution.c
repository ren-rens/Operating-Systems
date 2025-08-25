#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>

typedef struct {
    uint32_t x;
    uint32_t y;
} pair_t;

void solve(int fd1, int fd2, int fd3, uint32_t fd2_size) {
    int read_bytes;
    pair_t p;

    while ((read_bytes = read(fd1, &p, sizeof(p))) > 0) {
        if (fd2_size < (p.x + p.y) * sizeof(uint32_t)) {
            errx(1, "Not enough size for file2!");
        }

        if (lseek(fd2, p.x * sizeof(uint32_t), SEEK_SET) == -1) {
            err(5, "Lseek error in file2!");
        }

        uint32_t num;
        for (uint32_t i = p.x; i < (p.x + p.y); i++) {
            if (read(fd2, &num, sizeof(num)) != sizeof(num)) {
                err(7, "Could not read from file2!");
            }

            if (write(fd3, &num, sizeof(num)) == -1) {
                err(6, "Could not write in file3!");
            }
        }
    }

    if (read_bytes == -1) {
        err(7, "Could not read from file1!");
    }
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        errx(1, "Two arguments needed!");
    }

    int fd1=open(argv[1], O_RDONLY);
    if (fd1 == -1) {
        err(2, "Could not open file1!");
    }

    int fd2=open(argv[2], O_RDONLY);
    if (fd2 == -1) {
        err(2, "Could not open file2!");
    }

    int fd3=open(argv[3], O_WRONLY|O_TRUNC|O_CREAT, 0666);
    if (fd3 == -1) {
        err(2, "Could not open file3!");
    }

    struct stat st;
    if (fstat(fd1, &st) == -1) {
        err(3, "Stat error");
    }

    if (st.st_size % sizeof(pair_t) != 0) {
        errx(1, "File1 size error!");
    }

    if (fstat(fd2, &st) == -1) {
        err(3, "Fstat error for file2!");
    }

    uint32_t fd2_size = st.st_size;

    solve(fd1, fd2, fd3, fd2_size);

    close(fd1);
    close(fd2);
    close(fd3);

    return 0;
}
