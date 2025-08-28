#include <err.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>

int main(int argc, char* argv[]) {
    if (argc != 2) {
        errx(1, "invalid input in bar: one argument needed!");
    }

    int fd = open("foo_to_bar", O_RDONLY);
    if (fd == -1) {
        err(2, "open error");
    }

    if (dup2(fd, 0) == -1) {
        err(3, "dup2 error in bar");
    }

    execlp(argv[1], argv[1], (char*)NULL);
    err(4, "exec error in bar");

    return 0;
}
