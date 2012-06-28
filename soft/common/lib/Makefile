# Definition des outils
CC_PREFIX= lm32-elf-
CC = $(CC_PREFIX)gcc

STDIO_DEP = memcpy.o   system.o printf.o  strcmp.o  strcpy.o  time.o ftoa.o
STDLIB_DEP = exit.o  malloc.o

INCLUDES = ./include

SPECFLAGS  = -gstabs+ -mmultiply-enabled -mbarrel-shift-enabled
CFLAGS +=  -Wall -g -O2 -I. -ggdb -I$(INCLUDES) $(SPECFLAGS)

vpath %.c src

.PHONY: all clean cleanobjs

all:libc.a

libc.a: $(STDIO_DEP) $(STDLIB_DEP)
	ar rcs $@ $^
	make cleanobjs

%.o : %.c
	$(CC) -o $@ $(CFLAGS) -c $<

cleanobjs:
	rm -f $(STDIO_DEP) $(STDLIB_DEP)

clean:
	rm -f libc.a
