#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <err.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

const char words[3][4] = { "tic ", "tac ", "toe\n"};
int pfd[8][2];
int WC = 0;
int NC = 0;

void print_words(int write_to, int read_from) {
    int count;

    while(read(read_from, &count, sizeof(count)) == sizeof(count)) {
        if (count >= WC) {
            // close
            if (write(write_to, &count, sizeof(count)) == -1) {
                err(4, "write error: in pipe");
            }

            close(read_from);
            close(write_to);
            exit(0);
        }

        if (write(1, words[count % 3], 4) == -1) {
            err(4, "write error: stdout");
        }

        count++;

        if (write(write_to, &count, sizeof(count)) == -1) {
            err(4, "write error: in pipe");
        }
    }
}

void assign_pipes(void) {
    for (int i = 0; i < NC; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            err(3, "fork error");
        }

        if (pid == 0) {
            // child

            for (int j = 0; j <= NC; j++){
                                if (j == i){
                                        close(pfd[j][1]);
                                }
                                else if (j == i + 1){
                                        close(pfd[j][0]);
                                }
                                else {
                                        close(pfd[j][0]);
                                        close(pfd[j][1]);
                                }
                        }

                        print_words(pfd[i + 1][1], pfd[i][0]);
                        exit(0);
        }
    }

    for(int j = 0; j <= NC; j++){
                if (j == NC){
                        close(pfd[j][1]);
                }
                else if (j == 0){
                        close(pfd[0][0]);
                }
                else {
                        close(pfd[j][0]);
                        close(pfd[j][1]);
                }
        }

    int count = 0;
    if (write(pfd[0][1],&count,sizeof(count)) != sizeof(count)){
        err(4,"err writing to first pipe");
    }

        print_words(pfd[0][1], pfd[NC][0]);
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "invalid intpu: 2 arguments needed");
    }
    
    NC = strtol(argv[1], NULL, 10);
    if (NC < 1 || NC > 7) {
        errx(1, "invalid input: NC must be [1,7]");
    }

    WC = strtol(argv[2], NULL, 10);
    if (WC < 1 || WC > 35) {
        errx(1, "invalid input: WC must be [1,35]");
    }

    for (int i = 0; i <= NC; i++) {
        if (pipe(pfd[i]) == -1) {
            err(2, "pipe error");
        }
    }

    assign_pipes();

    return 0;
}
