CC=gcc
CFLAGS=-Wall -Wextra -O2 -rdynamic -DMAX_DICT_CELLS="(65535)"
LDFLAGS= -g -lm -ldl

SRCS= uforth.c uforth-ext.c utils.c 
HDRS= uforth.h uforth-ext.h
OBJS= uforth-ext.o uforth.o utils.o

TARGET=uforth-linux

uforth-linux: $(OBJS) uforth-linux.o  ext.f
	$(CC) $(CFLAGS) -o uforth-linux $(OBJS) uforth-linux.o $(LDFLAGS) -lreadline -lm
	echo "save-image uforth.img" | ./uforth-linux

dict:
	echo 'save-image uforth.img' | ./uforth-linux

uforth-stm32: dict $(OBJS) uforth-stm32.o ext.f
	$(CC) -o uforth-stm32 $(OBJS) uforth-stm32.o


ext.f: uforth-ext.h
	awk -f make_ext_words.awk uforth-ext.h > ext.f

depend:
	makedepend -- $(CFLAGS) -- $(SRCS)

clean:
	-rm -f *.o *.exe uforth.img* uforth-linux *~ *.stackdump *.aft-TOC uforth
