//
//  jit.m
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-05-08.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <inttypes.h>
int callps() {
    char *address = "127.0.0.1";
    int port = 24602;
    
    
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in server;
    server.sin_addr.s_addr = inet_addr(address);
    server.sin_family = AF_INET;
    server.sin_port = htons(port);
    connect(sock, (struct sockaddr *)&server, sizeof(server));
    close(sock);
    return 0;
}

int jit(int argc, char *argv[]) {
    // Define the address and port of the LLDB server
    char *address = "127.0.0.1";
    int port = 24601;

//    pid_t pid = 9845;
 pid_t pid = atoi(argv[1]);

    // Create a socket and connect to the LLDB server
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in server;
    server.sin_addr.s_addr = inet_addr(address);
    server.sin_family = AF_INET;
    server.sin_port = htons(port);
    connect(sock, (struct sockaddr *)&server, sizeof(server));

    // Send the vAttach packet to the LLDB server
    char packet[256];
//    sprintf(packet, "vAttach;pid:%d", getpid());
sprintf(packet, "$QStartNoAckMode#b0");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "+");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qSupported:xmlRegisters=i386,arm,mips,arc;multiprocess+;fork-events+;vfork-events+#2e");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$QEnableCompression:type:lzfse;#bf");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$QThreadSuffixSupported#e4");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$QListThreadsInStopReply#21");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$vCont?#49");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qVAttachOrWaitSupported#38");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$QEnableErrorStrings#8c");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qHostInfo#9b");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qProcessInfo#dc");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qC#b4");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qfThreadInfo#bb");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$qProcessInfo#dc");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$vAttach;%" PRIx64 "#d4", (uint64_t)pid);
   send(sock, packet, strlen(packet), 0);
sleep(2);
/*sprintf(packet, "$z0,1ce6fc0f8,4#fc");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$z0,1f2bff078,4#cc");
   send(sock, packet, strlen(packet), 0);
*/
sprintf(packet, "$D#44");
   send(sock, packet, strlen(packet), 0);

sprintf(packet, "$k#6b");
   send(sock, packet, strlen(packet), 0);
// Close the socket
    close(sock);

    return 0;
}

