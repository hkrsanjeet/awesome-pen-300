#### Use this command for compilling

Make sure compiler is installed
`sudo apt install musl-tools`

- when compiling normal file
`musl-gcc -static -Os -s -o test.elf test.c`
- when compiling reverseshell.
`musl-gcc -static -Os -s -o rev.elf rev.c -z execstack`
