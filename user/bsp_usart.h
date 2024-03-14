#ifndef __BSP_USART_H__
#define __BSP_USART_H__

#include "stm32f10x.h"
#include <stdio.h>

// 串口1 - USART1
#define DEBUG_USARTx                USART1
#define DEBUG_USART_CLK                   RCC_APB2Periph_USART1
#define DEBUG_USART_APBxClkCmd                   RCC_APB2PeriphClockCmd
#define DEBUG_USART_BAUDRATE                   115200

// USART GPIO 引脚宏定义
#define DEBUG_USART_GPIO_CLK            (RCC_APB2Periph_GPIOA)
#define DEBUG_USART_GPIO_APBxClkCmd         RCC_APB2PeriphClockCmd

#define DEBUG_USART_TX_GPIO_PORT            GPIOA
#define DEBUG_USART_TX_GPIO_PIN            GPIO_Pin_9
#define DEBUG_USART_RX_GPIO_PORT            GPIOA
#define DEBUG_USART_RX_GPIO_PIN            GPIO_Pin_10

#define DEBUG_USART_IRQ                     USART1_IRQn
#define DEBUG_USART_IRQHandler              USART1_IRQHandler



/*--------------------- 库函数 ---------------------*/
void USART_Conf(void);
void USART_SendByte(USART_TypeDef *pUSARTx, uint8_t data);
void USART_SendHalfWord(USART_TypeDef *pUSARTx, uint16_t data);
void USART_SendArray(USART_TypeDef *pUSARTx, uint8_t *arr, uint8_t num);
void USART_SendStr(USART_TypeDef *pUSARTx, const char *str);

#endif