#include <err.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>

int main(int argc, char* argv[]) {
    if (argc != 2) {
        errx(1, "invalid input in foo: one argument needed");
    }

    if (mkfifo("foo_to_bar", 0666) == -1) {
        err(2, "mkfifo error");
    }

    int fd = open("foo_to_bar", O_WRONLY);
    if (fd == -1) {
        err(3, "open error");
    }

    if (dup2(fd, 1) == -1) {
        err(4, "dup2 error in foo");
    }

    execlp("cat", "cat", argv[1], (char*)NULL);
    err(5, "exec error in foo");

    return 0;
}
