# fwlib source file list

FWLIB_CMSIS  = ./fwlib/CMSIS
FWLIB_PERIPH = ./fwlib/STM32F10x_StdPeriph_Driver
FW_SRC =
FW_INC =

# C file list
FW_SRC += $(FWLIB_CMSIS)/core_cm3.c
FW_SRC += $(FWLIB_CMSIS)/system_stm32f10x.c
FW_SRC += $(FWLIB_PERIPH)/src/misc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_adc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_bkp.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_can.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_cec.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_crc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_dac.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_dbgmcu.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_dma.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_exti.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_flash.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_fsmc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_gpio.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_i2c.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_iwdg.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_pwr.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_rcc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_rtc.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_sdio.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_spi.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_tim.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_usart.c
FW_SRC += $(FWLIB_PERIPH)/src/stm32f10x_wwdg.c


# C head file path
FW_INC += -I$(FWLIB_CMSIS)
FW_INC += -I$(FWLIB_PERIPH)/inc