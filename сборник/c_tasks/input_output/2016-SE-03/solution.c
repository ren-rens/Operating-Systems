#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

void write_half_elements (int size, int start, int fd, int fd_temp) {
    uint32_t buff;
    for (int i = 0; i < size; i++) {
        if (lseek(fd_temp, i * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: temp file");
        }

        if (lseek(fd, (start + i) * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: file");
        }

        if (read(fd, &buff, sizeof(buff)) == -1) {
            err(5, "read error: file");
        }

        if (write(fd_temp, &buff, sizeof(buff)) == -1) {
            err(6, "write error: temp file");
        }
    }
}

void write_final_elements(int i_temp, int i, int size, int fd_temp, int fd) {
    while (i_temp < size) {
        if (lseek(fd_temp, i_temp * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: temp file");
        }

        uint32_t buff;
        if (read(fd_temp, &buff, sizeof(buff)) == -1) {
            err(5, "read error: temp file");
        }

        if (write(fd, &buff, sizeof(buff)) == -1) {
            err(6, "write error: file");
        }

        i++;
        i_temp++;
    }
}

void merge(int fd, uint32_t left, uint32_t mid, uint32_t right) {
    int s1 = mid - left + 1;
    int s2 = right - mid;

    int fd1 = open("temp1.bin", O_RDWR|O_TRUNC|O_CREAT, 0644);
    if (fd1 == -1) {
        err(2, "open temp file error");
    }

    int fd2 = open("temp2.bin", O_RDWR|O_TRUNC|O_CREAT, 0644);
    if (fd2 == -1) {
        err(2, "open temp file error");
    }

    write_half_elements(s1, left, fd, fd1);
    write_half_elements(s2, mid + 1, fd, fd2);

    int i1 = 0;
    int i2 = 0;
    int i = left;

    while ((i1 < s1) && (i2 < s2)) {
        if (lseek(fd1, i1 * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: temp file");
        }

        if (lseek(fd2, i2 * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: temp file");
        }

        if (lseek(fd, i * sizeof(uint32_t), SEEK_SET) == -1) {
            err(4, "lseek error: file");
        }

        uint32_t buff1;
        uint32_t buff2;
        if (read(fd1, &buff1, sizeof(buff1)) == -1 || read(fd2, &buff2, sizeof(buff2)) == -1) {
            err(5, "read error: temp file");
        }

        if (buff1 < buff2) {
            if (write(fd, &buff1, sizeof(buff1)) == -1) {
                err(6, "write error: file");
            }
            i1++;
        } else {
            if (write(fd, &buff2, sizeof(buff2)) == -1) {
                err(6, "write error: file");
            }
            i2++;
        }
        i++;
    }

    write_final_elements(i1, i, s1, fd1, fd);
    write_final_elements(i2, i, s2, fd2, fd);

    close(fd1);
    close(fd2);
}

void merge_sort(int fd, uint32_t left, uint32_t right) {
    if (right <= left) {
        return;
    }

    uint32_t mid = left + (right - left) / 2;
    merge_sort(fd, left, mid);
    merge_sort(fd, mid + 1, right);

    merge(fd, left, mid, right);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        errx(1, "invalid input: one argument needed!");
    }

    int fd = open(argv[1], O_RDWR);
    if (fd == -1) {
        err(2, "open error");
    }

    struct stat st;
    if(fstat(fd, &st) == -1) {
        err(3, "%s", argv[1]);
    }

    if(st.st_size % sizeof(uint32_t) != 0) {
        errx(1, "bad size %li", st.st_size);
    }

    int size = st.st_size / sizeof(uint32_t);
    merge_sort(fd, 0, size - 1);

    close(fd);
    return 0;
}
