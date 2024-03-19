TARGERT=test

PREFIX=arm-none-eabi-
CC  = $(PREFIX)gcc
AS  = $(PREFIX)gcc -x assembler-with-cpp
CP  = $(PREFIX)objcopy
SZ  = $(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

mcu = cortext-m3
CPUFLAGS = -mthumb -mcpu=$(mcu)

# run code from flash
DDEFS   += -DSTM32F10X_HD -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000
DEFS	  = $(DDEFS) -DRUN_FROM_FLASH=1
#OBJECTS = $(ASM_SRC:.s=.o) $(SRC:.c=.o)

LDSCRIPT = ./stm32f103c8t6_flash.ld

AS_FLAGS = -mcpu$(mcu) -g -gdwarf-2 -mthumb  -Wa,-amhls=$(<:.s=.lst)
CP_FLAGS = -mcpu$(mcu) -Os -g -gdwarf-2 -mthumb -fomit-frame-pointer -Wall -fverbose-asm -Wa,-ahlms=$(<:.c=.lst) $(DEFS)
LD_FLAGS = -mcpu$(mcu) -g -gdwarf-2 -mthumb -nostartfiles \
           -Xlinker --gc-sections -T$(LDSCRIPT) -Wl,-Map=$(TARGERT).map,--cref,--no-warn-mismatch
#LDFLAGS = -T$(LDSCRIPT) \
          -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler \
		  -Wl,-Map=$(TARGERT).map \
		  -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group
#CFLAGS  = -g -o

OUTPUT = ./build/

# user dir
DEMO_DIR   := ./user/
SOURCE_C   := $(wildcard $(DEMO_DIR)*.c)
SOURCE_INC := $(wildcard $(DEMO_DIR)*.h)
DEMO_OBJ    = $(patsubst $(DEMO_DIR)%.c,$(OUTPUT)%.o,$(SOURCE_C))


# fwlib
FWLIB_CMSIS  = ./fwlib/CMSIS/
FWLIB_PERIPH = ./fwlib/STM32F1x_StdPeriph_Driver/
FW_SRC  = $(wildcard $(FWLIB_CMSIS)*.c)
FW_SRC += $(wildcard $(FWLIB_PERIPH)src/*.c)
FW_INC  = $(wildcard $(FWLIB_CMSIS)*.h)
FW_INC += $(wildcard $(FWLIB_PERIPH)inc/*.h)
FW_OBJ  = $(patsubst $(FWLIB_CMSIS)%.c,$(OUTPUT)fwlib/%.o,$(FW_SRC))
FW_OBJ  = $(patsubst $(FWLIB_PERIPH)src/%.c,$(OUTPUT)fwlib/%.o,$(FW_SRC))

# startup
ASM_SRC = ./startup/startup_stm32f103zetx.s
ASM_OBJ = $(ASM_SRC:.s=.o)

# FreeRTOS source
FREERTOS_DIR  = ./freertos/
FREERTOS_SRC  = $(wildcard $(FREERTOS_DIR)*.c)
FREERTOS_SRC += $(FREERTOS_DIR)/portable/GCC/ARM_CM3/port.c
FREERTOS_SRC += $(FREERTOS_DIR)/portable/MemMang/heap4.c
FREERTOS_INC  = $(wildcard $(FREERTOS_DIR)/include/*.h)
FREERTOS_INC += $(FREERTOS_DIR)/portable/GCC/ARM_CM3/portmacro.h
FREERTOS_OBJ  = $(patsubst $(FREERTOS_SRC)$.c,) 

$(TARGERT):startup_stm32f10x_md.o main.o
$(CC) $^ $(CPUFLAGS) $(LDFLAGS) $(CFLAGS) $(TARGERT).elf

startup_stm32f10x_md.o:startup_stm32f10x_md.s
  $(CC) -c $^ $(CPUFLAGS) $(CFLAGS) $@

bin:
  $(CP) $(TARGERT).elf $(TARGERT).bin
hex:
  $(CP) $(TARGERT).elf -Oihex $(TARGERT).hex

clean: