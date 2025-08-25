#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

void generate_file(int fd1, int fd2) {
    uint8_t curr_byte;
    int8_t read_bytes;

    while ((read_bytes = read(fd1, &curr_byte, sizeof(uint8_t))) > 0) {
        if (curr_byte == 0x55) {
            // starting new message
            uint8_t N = 0;
            uint8_t data[1024];
            uint8_t idx = 0;
            uint8_t checksum = curr_byte;

            if (read(fd1, &N, sizeof(uint8_t)) == -1) {
                err(3, "read error: N");
            }

            printf("N: %d\n", N);

            if (N < 4) {
                warnx("invalid input for file1: N");
                continue;
            }

            checksum ^= N;

            for (uint8_t i = 3; i <= N - 1; i++) {
                if (read(fd1, &data[idx], sizeof(uint8_t)) == -1) {
                    err(3, "read error: data");
                }

                printf("data: %d\n", data[idx]);
                checksum ^= data[idx++];
            }

            uint8_t curr_checksum;
            if (read(fd1, &curr_checksum, sizeof(uint8_t)) == -1) {
                err(3, "read error: checksum");
            }

            printf("checksum: %d curr_checksum: %d\n", checksum, curr_checksum);

            if (checksum != curr_checksum) {
                warnx("invalid input: wrong checksum");
                continue;
            }

            if (write(fd2, &curr_byte, sizeof(uint8_t)) == -1 ||
                write(fd2, &N, sizeof(uint8_t)) == -1 ||
                write(fd2, data, N - 4) == -1 ||
                write(fd2, &checksum, sizeof(uint8_t)) == -1) {
                err(4, "write error");
            }
        }
    }

    if (read_bytes == -1) {
        err(3, "read error: file1");
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "invalid input: 2 arguments needed!");
    }

    int fd1 = open(argv[1], O_RDONLY);
    if (fd1 == -1) {
        err(2, "open error: file1");
    }

    int fd2 = open(argv[2], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (fd2 == -1) {
        err(2, "open error: file2");
    }

    generate_file(fd1, fd2);

    return 0;
}
