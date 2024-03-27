# user source file list

DEMO_DIR  := ./user
USER_SRC   =
USER_INC   =

# C file
USER_SRC  += $(DEMO_DIR)/bsp_usart.c
USER_SRC  += $(DEMO_DIR)/main.c
USER_SRC  += $(DEMO_DIR)/stm32f10x_it.c


# C head file
USER_INC  += -I$(DEMO_DIR)