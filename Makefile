TARGERT=test
OUTPUT = ./build/
BINDIR = ./bin/

PREFIX=arm-none-eabi-
CC  = $(PREFIX)gcc
AS  = $(PREFIX)gcc -x assembler-with-cpp
CP  = $(PREFIX)objcopy
SZ  = $(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

obj :=
inc :=

# run code from flash
DDEFS   += -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000
DEFS	 = $(DDEFS) -DRUN_FROM_FLASH=1
LDSCRIPT = ./stm32f103c8t6_flash.ld

mcu      = cortex-m3
CPUFLAGS = -mthumb -mcpu=$(mcu)
AS_FLAGS = -mcpu=$(mcu) -g -gdwarf-2 -mthumb -Wa,-amhls=$(OUTPUT)$(notdir $(<:.s=.lst))
CP_FLAGS = -mcpu=$(mcu) -Og -g -gdwarf-2 -mthumb -fomit-frame-pointer -lm -lc -lnosys \
			-Wall -fverbose-asm -Wa,-amhls=$(OUTPUT)$(notdir $(<:.c=.lst)) $(DEFS)
LD_FLAGS = -mcpu=$(mcu) -specs=nosys.specs -g -gdwarf-2 -mthumb -nostartfiles \
           -Xlinker --gc-sections -T$(LDSCRIPT) -Wl,-Map=$(TARGERT).map,--cref,--no-warn-mismatch

# addition Makefile
include ./user/Makefile.mk
include ./fwlib/Makefile.mk
include ./freertos/Makefile.mk

# startup
ASM_SRC = ./startup/startup_stm32f10x_md.s
ASM_OBJ = $(addprefix $(OUTPUT),$(notdir $(ASM_SRC:.s=.o)))

src += $(USER_SRC) $(FW_SRC) $(FREERTOS_SRC)
obj += $(addprefix $(OUTPUT),$(notdir $(src:.c=.o)))
inc += $(USER_INC) $(FW_INC) $(FREERTOS_INC)
vpath %.c $(sort $(dir $(src)))

# default action: build all
all: $(ASM_OBJ) $(obj) $(OUTPUT)$(TARGERT).elf $(BINDIR)$(TARGERT).hex $(BINDIR)$(TARGERT).bin

$(OUTPUT)%.o: %.c
	$(CC) -c $(CP_FLAGS) $(inc) $< -o $@

$(ASM_OBJ): $(ASM_SRC)
	$(AS) -c $(AS_FLAGS) $< -o $@

$(OUTPUT)$(TARGERT).elf: $(obj) $(ASM_OBJ)
	$(CC) $(LD_FLAGS) $^ -o $@
	$(SZ) $@

$(BINDIR)%.hex: $(OUTPUT)%.elf
	$(HEX) $< $@

$(BINDIR)%.bin: $(OUTPUT)%.elf
	$(BIN) $< $@

.PHONY:clean
clean:
	rm -rf $(OUTPUT)*
	rm -rf $(BINDIR)*
	rm test.map