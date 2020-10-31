CC ?= 
CC_CROSS := $(CC)
CFLAGS ?= -Wall -Wextra -pedantic -O3 -DMAX_DICT_CELLS="(8192)"
LDFLAGS ?= 
CFLAGS_CROSS := $(CFLAGS)
LDFLAGS_CROSS := $(LDFLAGS)

CC_LINUX := gcc
CFLAGS_LINUX := -Wall -Wextra -pedantic -O3 -rdynamic -DMAX_DICT_CELLS="(65535)"
LDFLAGS_LINUX := -lm -ldl -lreadline

BASE_SRCS := uforth.c uforth-ext.c utils.c 

BASE_OBJS := $(patsubst %.c, %.o, $(BASE_SRCS))

TOOLCHAIN := LINUX

.PHONY: clean clean-objs linux cross riot stm32

TARGET: linux

ext.f: uforth-ext.h
	awk -f make_ext_words.awk uforth-ext.h > ext.f

%.o: %.c
	$(CC_$(TOOLCHAIN)) -c $(CFLAGS_$(TOOLCHAIN)) $< -o $@

uforth-linux: TOOLCHAIN = LINUX
uforth-linux: $(BASE_OBJS) uforth-linux.o  ext.f
	$(CC_LINUX) -o uforth-linux $(BASE_OBJS) uforth-linux.o $(LDFLAGS_LINUX)

uforth.img: uforth-linux
	echo 'save-image uforth.img' | ./uforth-linux

uforth.img.h: uforth.img

uforth-cross: TOOLCHAIN = CROSS
uforth-cross: uforth.img.h $(BASE_OBJS) uforth-$(CROSS_TARGET).o ext.f
	$(CC_CROSS) -o uforth-$(CROSS_TARGET) $(BASE_OBJS) uforth-$(CROSS_TARGET).o $(LDFLAGS_CROSS)

clean-objs:
	-rm -f *.o

clean-img:
	-rm -f uforth.img*

clean: clean-objs clean-img
	-rm -f uforth-riot uforth-linux uforth-stm32 *~ *.stackdump *.aft-TOC uforth ext.f

linux: uforth-linux clean-objs

cross: linux uforth.img.h uforth-cross clean-objs

riot: CROSS_TARGET = riot
riot: cross

stm32: CROSS_TARGET = stm32
stm32: cross
