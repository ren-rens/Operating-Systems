#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>

uint16_t encode_half(uint8_t byte) {
    uint16_t result = 0;

    for(int i = 0; i < 4; i++) {
            result <<= 2;
            result |= ((byte & 0x80) == 0) ? 0x01 : 0x02;
            byte <<= 1;
        }

    return result;
}

void encoder(int fd_write, int fd_read, int size) {
    for (int i = 0; i < size; i++) {
        uint8_t num;
        if (read(fd_read, &num, sizeof(num)) == -1) {
            err(4, "read error");
        }

        uint8_t encoded = 0;
        encoded |= encode_half(num);
        if (write(fd_write, &encoded, sizeof(encoded)) == -1) {
            err(5, "write error");
        }

        encoded = 0;
        encoded |= (encode_half(num << 4));

        if (write(fd_write, &encoded, sizeof(encoded)) == -1) {
            err(5, "write error");
        }
    }
}


int main(int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "invalid input: 2 arguments needed");
    }

    int fd_read = open(argv[1], O_RDONLY);
    if (fd_read == -1) {
        err(2, "open error: read file");
    }

    int fd_write = open(argv[2], O_WRONLY|O_TRUNC|O_CREAT, 0644);
    if (fd_write == -1) {
        err(2, "open error: write file");
    }

    struct stat st;
    if (fstat(fd_read, &st) == -1) {
        err(3, "fstat error");
    }

    int size = st.st_size / sizeof(uint8_t);
    encoder(fd_write, fd_read, size);

        close(fd_read);
        close(fd_write);

        return 0;
}
