#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    uint16_t ram_size;
    uint16_t register_count;
    char filename[8];
} reg_t;

void execute(const reg_t* r) {
    int curr_fd = open(r->filename, O_RDWR);
    if (curr_fd == -1) {
        err(2, "open current file");
    }

    uint8_t register_values[32] = {0};
    uint8_t ram_init [512] = {0};
    uint8_t instructions[4];
        // instructions:
        // opcode
        // op1
        // op2
        // op3

    if (read(curr_fd, register_values, r->register_count) != r->register_count) {
        err(3, "read error: register values");
    }

    if (read(curr_fd, ram_init, r->ram_size) != r->ram_size) {
        err(3, "read error: register values");
    }

    off_t instr_start = lseek(curr_fd, 0, SEEK_CUR);

    int read_bytes;
    while ((read_bytes = read(curr_fd, instructions, sizeof(instructions))) > 0) {
        // per each instruction start a process
        uint8_t opcode = instructions[0];
        uint8_t op1 = instructions[1];
        uint8_t op2 = instructions[2];
        uint8_t op3 = instructions[3];

        switch (opcode) {
            case 0:
                register_values[op1] = register_values[op2] & register_values[op3];
                break;
            case 1:
                register_values[op1] = register_values[op2] | register_values[op3];
                break;
            case 2:
                register_values[op1] = register_values[op2] + register_values[op3];
                break;
            case 3:
                register_values[op1] = register_values[op2] * register_values[op3];
                break;
            case 4:
                register_values[op1] = register_values[op2] ^ register_values[op3];
                break;
            case 5:
                if (write(1, &register_values[op1], sizeof(register_values[op1])) == -1) {
                    err(4, "write error: stdout register[op1]");
                }
                break;
            case 6:
                sleep(register_values[op1]);
                break;
            case 7:
                register_values[op1] = ram_init[register_values[op2]];
                break;
            case 8:
                ram_init[register_values[op2]] = register_values[op1];
                break;
            case 9:
                if (register_values[op1] != register_values[op2]) {
                    // start from op3 instrcution
                    off_t offset = instr_start + op3 * 4;
                    if (lseek(curr_fd, offset, SEEK_SET) == -1)
                        err(5, "lseek err");
                    }
                break;
            case 10:
                register_values[op1] = op2;
                break;
            case 11:
                ram_init[register_values[op1]] = op2;
                break;
            default: errx(1, "invalid input: opcode does not exists");
        }
   }

    if (lseek(curr_fd, 0, SEEK_SET) == -1) {
        err(7, "lseek errror");
    }

    if (write(curr_fd, register_values, r->register_count) != r->register_count) {
        err(4, "write error: register values");
    }

    if (write(curr_fd, ram_init, r->ram_size) != r->ram_size) {
        err(4, "write error: ram values");
    }

    close(curr_fd);
    exit(0);
}

void read_register_file(int fd) {
    reg_t r;
    int read_bytes;

    while((read_bytes = read(fd, &r, sizeof(r))) == sizeof(r)) {
        pid_t pid = fork();
        if (pid == -1) {
            err(5, "fork error");
        }

        if (pid == 0) {
            execute(&r);
        }
    }

    if (read_bytes == -1) {
        err(3, "read error: register file");
    }

    while(wait(NULL) > 0);
}


int main(int argc, char* argv[]) {
    if (argc != 2) {
        errx(1, "invalid input: one argument needed!");
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        err(2, "open error");
    }

    read_register_file(fd);
    close(fd);

        return 0;
}
