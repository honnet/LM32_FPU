# Definition des outils
CC_PREFIX= lm32-elf-
CC = $(CC_PREFIX)gcc
AS = $(CC_PREFIX)as
LD = $(CC_PREFIX)ld
OBJDUMP = $(CC_PREFIX)objdump
OBJCOPY = $(CC_PREFIX)objcopy
SREC_CAT = srec_cat

# Le fichier elf cible
SOFT_IMAGE = soft.elf

# Fichier binaire qui sera enregistré dans la bram
SOFT_SREC = soft.srec
SOFT_VM = soft.vm

# Definition des objets
OBJS       = boot.o ram_init.o main.o 

LIB=../common/lib
SIMPLE_LIB_C = $(LIB)/libc.a

SPECFLAGS  =   -gstabs+ -mmultiply-enabled -mbarrel-shift-enabled
CFLAGS +=  -Wall -g -O2 -I. -ggdb -I$(LIB)/include $(SPECFLAGS)

LD_SCRIPT = bootldscript
# Attention lm32-elf-gcc (version 4.2.1 (LatticeMico32) 7.0.1 SRCE) a des specs non standards
# et s'attend à recevoir une option -T avec le script de link directement
LDFLAGS   = $(SPECFLAGS) -L$(LIB) -nostartfiles -T $(LD_SCRIPT) -Wl,--print-map -Wl--cref 

.PHONY: all clean copy

all : copy

copy : $(SOFT_VM)
	cp soft.vm ../../target/syn/quartus
	cp soft.vm ../../simulation

$(SOFT_VM) : $(SOFT_SREC)
	$(SREC_CAT) $(SOFT_SREC) -Output $(SOFT_VM) -Vmem 32

$(SOFT_SREC) : $(SOFT_IMAGE)
	$(OBJCOPY) -O srec $(SOFT_IMAGE) $(SOFT_SREC)

$(SOFT_IMAGE): $(LD_SCRIPT) $(OBJS) $(SIMPLE_LIB_C)
	$(CC)  $(LDFLAGS) -o $@ $(filter %.o,$^) > $@.ldmap


%.o: %.s
	$(AS) $< -o $@

%.o : %.S
	$(CC) -o $@ $(CFLAGS) -c $<

%.o : %.c
	$(CC) -o $@ $(CFLAGS) -c $<

clean :
	rm -f $(SOFT_IMAGE) $(SOFT_SREC) $(SOFT_VM) $(OBJS) *.ldmap

$(SIMPLE_LIB_C):
	make -C $(LIB)
