include ../../Makefile.in
CFLAGS += -I/home/pli/workspace/excalibur/src/inc

TARGET = print.o
all:$(TARGET)

.s.o:
	nasm $(ASFLAGS) -o $@ $<
.c.o:
	cc $(CFLAGS) -o $@ $<
