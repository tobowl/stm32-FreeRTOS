# FreeRTOS source file list

FREERTOS_DIR = ./freertos
FREERTOS_SRC =
FREERTOS_INC =

# FreeRTOS C file list
FREERTOS_SRC += $(FREERTOS_DIR)/croutine.c
FREERTOS_SRC += $(FREERTOS_DIR)/event_groups.c
FREERTOS_SRC += $(FREERTOS_DIR)/list.c
FREERTOS_SRC += $(FREERTOS_DIR)/queue.c
FREERTOS_SRC += $(FREERTOS_DIR)/stream_buffer.c
FREERTOS_SRC += $(FREERTOS_DIR)/tasks.c
FREERTOS_SRC += $(FREERTOS_DIR)/timers.c
FREERTOS_SRC += $(FREERTOS_DIR)/portable/GCC/ARM_CM3/port.c
FREERTOS_SRC += $(FREERTOS_DIR)/portable/MemMang/heap_4.c


# FreeRTOS C head path
FREERTOS_INC += -I$(FREERTOS_DIR)/include
FREERTOS_INC += -I$(FREERTOS_DIR)/portable/GCC/ARM_CM3