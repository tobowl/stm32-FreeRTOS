TARGERT=test

PREFIX=arm-none-eabi-
CC  = $(PREFIX)gcc
AS  = $(PREFIX)gcc -x assembler-with-cpp
CP  = $(PREFIX)objcopy
SZ  = $(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

obj :=
inc :=

mcu = cortext-m3
CPUFLAGS = -mthumb -mcpu=$(mcu)

# run code from flash
DDEFS   += -DSTM32F10X_HD -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000
DEFS	  = $(DDEFS) -DRUN_FROM_FLASH=1

LDSCRIPT = ./stm32f103c8t6_flash.ld

AS_FLAGS = -mcpu$(mcu) -g -gdwarf-2 -mthumb  -Wa,-amhls=$(<:.s=.lst)
CP_FLAGS = -mcpu$(mcu) -Os -g -gdwarf-2 -mthumb -fomit-frame-pointer -Wall -fverbose-asm -Wa,-ahlms=$(<:.c=.lst) $(DEFS)
LD_FLAGS = -mcpu$(mcu) -g -gdwarf-2 -mthumb -nostartfiles \
           -Xlinker --gc-sections -T$(LDSCRIPT) -Wl,-Map=$(TARGERT).map,--cref,--no-warn-mismatch

OUTPUT = ./build/
BINDIR = ./bin/

# user dir
DEMO_DIR   := ./user/
SOURCE_C   := $(wildcard $(DEMO_DIR)*.c)
SOURCE_INC := $(wildcard $(DEMO_DIR)*.h)

# fwlib
FWLIB_CMSIS  = ./fwlib/CMSIS/
FWLIB_PERIPH = ./fwlib/STM32F10x_StdPeriph_Driver/
FW_SRC := $(wildcard $(FWLIB_CMSIS)*.c)
FW_SRC += $(wildcard $(FWLIB_PERIPH)src/*.c)
FW_INC := $(wildcard $(FWLIB_CMSIS)*.h)
FW_INC += $(wildcard $(FWLIB_PERIPH)inc/*.h)

# startup
ASM_SRC = ./startup/startup_stm32f103c8t6.s
ASM_OBJ = $(ASM_SRC:.s=.o)
$(info $(ASM_OBJ))

# FreeRTOS source
FREERTOS_DIR  = ./freertos/
FREERTOS_SRC  = $(wildcard $(FREERTOS_DIR)*.c)
FREERTOS_SRC += $(FREERTOS_DIR)/portable/GCC/ARM_CM3/port.c
FREERTOS_SRC += $(FREERTOS_DIR)/portable/MemMang/heap4.c
FREERTOS_INC  = $(wildcard $(FREERTOS_DIR)/include/*.h)
FREERTOS_INC += $(FREERTOS_DIR)/portable/GCC/ARM_CM3/portmacro.h

src := $(DEMO_SRC) $(FW_SRC) $(FREERTOS_SRC)
obj := $(addprefix $(OUTPUT),$(notdir $(src:.c=.o)))
$(info $(obj))
inc += $(SOURCE_INC) $(FW_INC) $(FREERTOS_INC)
CP_FLAGS += $(inc)

all: $(OUTPUT)$(TARGERT).elf $(BINDIR)$(TARGERT).bin $(BINDIR)$(TARGERT).hex

$(OUTPUT)%.o: %.c Makefile | $(OUTPUT)
	$(CC) -c $(CP_FLAGS) -I . $(inc) $< -o $@

$(OUTPUT)%.o: %.s Makefile | $(OUTPUT)
	$(AS) -c $(AS_FLAGS) $< -o $@

$(OUTPUT)%.elf: $(obj)
	$(CC) $(obj) $(LD_FLAGS) -o $@
	$(SZ) $@

$(BINDIR)%.hex: $(OUTPUT)%.elf | $(OUTPUT)
	$(HEX) $< $@

$(BINDIR)%.bin: $(OUTPUT)%.elf | $(OUTPUT)
	$(BIN) $< $@

#$(TARGERT):startup_stm32f10x_md.o main.o
#$(CC) $^ $(CPUFLAGS) $(LDFLAGS) $(CFLAGS) $(TARGERT).elf

#startup_stm32f10x_md.o:startup_stm32f10x_md.s
#  $(CC) -c $^ $(CPUFLAGS) $(CFLAGS) $@

#bin:
#  $(CP) $(TARGERT).elf $(TARGERT).bin
#hex:
#  $(CP) $(TARGERT).elf -Oihex $(TARGERT).hex

clean:
	rm -rf $(obj)