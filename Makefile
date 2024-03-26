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

mcu = cortex-m3
CPUFLAGS = -mthumb -mcpu=$(mcu)

# run code from flash
DDEFS   += -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000
DEFS	  = $(DDEFS) -DRUN_FROM_FLASH=1

LDSCRIPT = ./stm32f103c8t6_flash.ld

AS_FLAGS = -mcpu=$(mcu) -g -gdwarf-2 -mthumb  -Wa,-amhls=$(<:.s=.lst)
CP_FLAGS = -mcpu=$(mcu) -Og -g -gdwarf-2 -mthumb -fomit-frame-pointer -lm -lc -lnosys \
			-Wall -fverbose-asm -Wa,-amhls=$(OUTPUT)$(notdir $(<:.c=.lst)) $(DEFS)
LD_FLAGS = -mcpu=$(mcu) -specs=nano.specs -g -gdwarf-2 -mthumb -nostartfiles \
           -Xlinker --gc-sections -T$(LDSCRIPT) -Wl,-Map=$(TARGERT).map,--cref,--no-warn-mismatch
# CP_FLAGS += -MMD -MP "$(@:%.o=%.d)"
OUTPUT = ./build/
BINDIR = ./bin/

# user dir
DEMO_DIR   := ./user/
SOURCE_C   := $(wildcard $(DEMO_DIR)*.c)
SOURCE_INC := $(DEMO_DIR)

# fwlib
FWLIB_CMSIS  = -I./fwlib/CMSIS/
FWLIB_PERIPH = -I./fwlib/STM32F10x_StdPeriph_Driver/
FW_SRC := $(wildcard $(FWLIB_CMSIS)*.c)
FW_SRC += $(wildcard $(FWLIB_PERIPH)src/*.c)
FW_INC := $(FWLIB_CMSIS)
FW_INC += $(FWLIB_PERIPH)inc/

# startup
ASM_SRC = ./startup/startup_stm32f10x_md.s
ASM_OBJ = $(addprefix $(OUTPUT),$(notdir $(ASM_SRC:.s=.o)))

# FreeRTOS source
FREERTOS_DIR  = ./freertos/
FREERTOS_SRC  = $(wildcard $(FREERTOS_DIR)*.c)
FREERTOS_SRC += $(FREERTOS_DIR)portable/GCC/ARM_CM3/port.c
FREERTOS_SRC += $(FREERTOS_DIR)portable/MemMang/heap_4.c
FREERTOS_INC  = -I$(FREERTOS_DIR)include/
FREERTOS_INC += -I$(FREERTOS_DIR)portable/GCC/ARM_CM3/

src += $(SOURCE_C) $(FW_SRC) $(FREERTOS_SRC)
obj += $(addprefix $(OUTPUT),$(notdir $(src:.c=.o)))
inc += $(SOURCE_INC) $(FW_INC) $(FREERTOS_INC)

# default action: build all
all: $(ASM_OBJ) $(obj) $(OUTPUT)$(TARGERT).elf $(BINDIR)$(TARGERT).hex $(BINDIR)$(TARGERT).bin

$(obj): $(src) Makefile | $(OUTPUT)
	$(CC) -c $(CP_FLAGS) -Wa,-a,-ad -I $(inc) $< -o $@

# %.o: $(ASM_SRC) Makefile | $(OUTPUT)
$(ASM_OBJ): $(ASM_SRC)
	$(AS) -c $(AS_FLAGS) $< -o $@

$(OUTPUT)$(TARGERT).elf: $(obj)
	$(CC) $(obj) $(ASM_OBJ) $(LD_FLAGS) -o $@
	$(SZ) $@

# $(BINDIR)%.hex: $(OUTPUT)%.elf | $(OUTPUT)
%.hex: %.elf
	$(HEX) $< $@

# $(BINDIR)%.bin: $(OUTPUT)%.elf | $(OUTPUT)
%.bin: %.elf
	$(BIN) $< $@

.PHONY:clean
clean:
	rm -rf $(obj)
	rm -rf $(ASM_OBJ)
	rm -rf ./startup/startup_stm32f10x_md.lst
	rm -rf ./startup/startup_stm32f10x_md.o
	rm -rf ./build/bsp_usart.o
	find . -name "*.gch" | xargs rm
	rm test.map