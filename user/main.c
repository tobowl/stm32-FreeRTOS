/*
 * FreeRTOS V202212.01
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
*/

/* Standard includes. */
#include <string.h>

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "stm32f10x.h"
#include "bsp_usart.h"

/*
 * Configure the clocks, GPIO and other peripherals as required by the demo.
 */
static void prvSetupHardware( void );
static void GPIO_LED_Conf(void);

/*-----------------------------------------------------------*/
void Task1_LED(void *param)
{
    GPIO_LED_Conf();
    const TickType_t xTickstoWait = pdMS_TO_TICKS(500);
    while (1)
    {
        GPIO_ResetBits(GPIOC, GPIO_Pin_13);
        vTaskDelay(xTickstoWait);
        GPIO_SetBits(GPIOC, GPIO_Pin_13);
        vTaskDelay(xTickstoWait);
    }
}

void Task2_Print(void *param)
{
    USART_Conf();
    const TickType_t xTickstoWait = pdMS_TO_TICKS(1000);
    while (1)
    {
        printf("Print Task is runing every 1 second...\n");
        vTaskDelay(xTickstoWait);
    }
}

void AppTask_Create(void *param)
{
    xTaskCreate(Task1_LED, "Task1_LED", 100, NULL, 1, NULL);
    xTaskCreate(Task2_Print, "Task2_Print", 100, NULL, 1, NULL);
}

int main( void )
{
    #ifdef DEBUG
        debug();
    #endif

    prvSetupHardware();

    /* Start the scheduler. */
    AppTask_Create(NULL);
    vTaskStartScheduler();
    // Task1_LED(NULL);

    /* Will only get here if there was not enough heap space to create the
    idle task. */
    while(1)
    {
    };
    return 0;
}
/*-----------------------------------------------------------*/

static void GPIO_LED_Conf(void)
{
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOC, &GPIO_InitStructure);
}

/*-----------------------------------------------------------*/

static void prvSetupHardware( void )
{
    /* Start with the clocks in their expected state. */
    RCC_DeInit();

    /* Enable HSE (high speed external clock). */
    RCC_HSEConfig( RCC_HSE_ON );

    /* Wait till HSE is ready. */
    while( RCC_GetFlagStatus( RCC_FLAG_HSERDY ) == RESET )
    {
    }

    /* 2 wait states required on the flash. */
    *( ( unsigned long * ) 0x40022000 ) = 0x02;

    /* HCLK = SYSCLK */
    RCC_HCLKConfig( RCC_SYSCLK_Div1 );

    /* PCLK2 = HCLK */
    RCC_PCLK2Config( RCC_HCLK_Div1 );

    /* PCLK1 = HCLK/2 */
    RCC_PCLK1Config( RCC_HCLK_Div2 );

    /* PLLCLK = 12MHz * 6 = 72 MHz. */
    RCC_PLLConfig( RCC_PLLSource_HSE_Div1, RCC_PLLMul_6 );

    /* Enable PLL. */
    RCC_PLLCmd( ENABLE );

    /* Wait till PLL is ready. */
    while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET)
    {
    }

    /* Select PLL as system clock source. */
    RCC_SYSCLKConfig( RCC_SYSCLKSource_PLLCLK );

    /* Wait till PLL is used as system clock source. */
    while( RCC_GetSYSCLKSource() != 0x08 )
    {
    }

    /* Enable GPIOA, GPIOB, GPIOC, GPIOD, GPIOE and AFIO clocks */
    RCC_APB2PeriphClockCmd(    RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB |RCC_APB2Periph_GPIOC
                            | RCC_APB2Periph_GPIOD | RCC_APB2Periph_GPIOE | RCC_APB2Periph_AFIO, ENABLE );

    /* SPI2 Periph clock enable */
    RCC_APB1PeriphClockCmd( RCC_APB1Periph_SPI2, ENABLE );


    /* Set the Vector Table base address at 0x08000000 */
    NVIC_SetVectorTable( NVIC_VectTab_FLASH, 0x0 );

    NVIC_PriorityGroupConfig( NVIC_PriorityGroup_4 );

    /* Configure HCLK clock as SysTick clock source. */
    SysTick_CLKSourceConfig( SysTick_CLKSource_HCLK );

    /* Misc initialisation, including some of the CircleOS features.  Note
    that CircleOS itself is not used. */
}
/*-----------------------------------------------------------*/

