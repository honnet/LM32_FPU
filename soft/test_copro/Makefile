# Definition des outils
CC_PREFIX= lm32-elf-
CC = $(CC_PREFIX)gcc
AS = $(CC_PREFIX)as
LD = $(CC_PREFIX)ld
OBJCOPY = $(CC_PREFIX)objcopy

# Le fichier elf cible
SOFT_IMAGE = soft.elf
BIN_IMAGE  = soft.bin
RAM_IMAGE  = soft.ram

# Definition des objets
OBJS       = crt0.o bss_init.o main.o 

LIB =../common/lib
SIMPLE_LIB_C = $(LIB)/libc.a

SPECFLAGS  =    -gstabs+ -mmultiply-enabled -mbarrel-shift-enabled -fsingle-precision-constant
CFLAGS +=  -Wall -g -O2 -I. -ggdb -I$(LIB)/include $(SPECFLAGS)

LD_SCRIPT = ../common/ldscript
# Attention lm32-elf-gcc (version 4.2.1 (LatticeMico32) 7.0.1 SRCE) a des specs non standards
# et s'attend à recevoir une option -T avec le script de link directement
LDFLAGS   = $(SPECFLAGS) -L$(LIB) -nostartfiles -T $(LD_SCRIPT) -Wl,--print-map -Wl--cref 

VPATH = . ../common

.PHONY: all clean 


all:$(RAM_IMAGE)


$(SOFT_IMAGE): $(LD_SCRIPT) $(OBJS) $(SIMPLE_LIB_C)
	$(CC)  $(LDFLAGS) -o $@ $(filter %.o,$^) > $@.ldmap


%.bin:%.elf
	$(OBJCOPY) -I elf32-lm32 -O binary $< $@

%.ram:%.bin
	od -An -v -w1 -t x1 $< | tr -d [:blank:] | tr -d '\n' > $@

%.o: %.s
	$(AS) $< -o $@

%.o : %.S
	$(CC) -o $@ $(CFLAGS) -c $<

%.o : %.c
	$(CC) -o $@ $(CFLAGS) -c $<

clean :
	rm -f $(RAM_IMAGE) $(BIN_IMAGE) $(SOFT_IMAGE) $(OBJS) *.ldmap

# au cas ou la lib n'est pas comilée
$(SIMPLE_LIB_C):
	make -C $(LIB)
