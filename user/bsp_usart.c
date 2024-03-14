#include "bsp_usart.h"

static void NVIC_Configuration(void)
{
    NVIC_InitTypeDef NVIC_InitStructure;

    // 嵌套向量中断控制器组选择
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);

    // 配置USART为中断源
    NVIC_InitStructure.NVIC_IRQChannel = DEBUG_USART_IRQ;
    // 抢断优先级
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
    // 子优先级
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
    // 使能中断
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;

    NVIC_Init(&NVIC_InitStructure);
}

void USART_Conf(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    USART_InitTypeDef USART_InitStructure;

    // 打开串口GPIO时钟
    DEBUG_USART_GPIO_APBxClkCmd(DEBUG_USART_GPIO_CLK, ENABLE);

    // 打开串口外设时钟
    DEBUG_USART_APBxClkCmd(DEBUG_USART_CLK, ENABLE);

    // 将USART Tx的 GPIO配置位推挽复用模式
    GPIO_InitStructure.GPIO_Pin = DEBUG_USART_TX_GPIO_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(DEBUG_USART_TX_GPIO_PORT, &GPIO_InitStructure);

    GPIO_InitStructure.GPIO_Pin = DEBUG_USART_RX_GPIO_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
    GPIO_Init(DEBUG_USART_RX_GPIO_PORT, &GPIO_InitStructure);


    // 配置串口的工作参数
    // 配置波特率
    USART_InitStructure.USART_BaudRate = DEBUG_USART_BAUDRATE;
    // 配置 帧数据字长
    USART_InitStructure.USART_WordLength = USART_WordLength_8b;
    // 配置停止位
    USART_InitStructure.USART_StopBits = USART_StopBits_1;
    // 配置校验位
    USART_InitStructure.USART_Parity = USART_Parity_No;
    // 配置硬件流控制
    USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
    // 配置工作模式
    USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
    // 完成串口初始化配置
    USART_Init(DEBUG_USARTx, &USART_InitStructure);

    // 串口中断优先级配置
    NVIC_Configuration();

    // 使能串口接收中断
    USART_ITConfig(DEBUG_USARTx, USART_IT_RXNE, ENABLE);

    // 使能串口
    USART_Cmd(DEBUG_USARTx, ENABLE);
}

// 发送一个字节
void USART_SendByte(USART_TypeDef *pUSARTx, uint8_t data)
{
    USART_SendData(pUSARTx, data);
    while (USART_GetFlagStatus(pUSARTx,USART_FLAG_TXE) == RESET);
}

// 发送两个字节
void USART_SendHalfWord(USART_TypeDef *pUSARTx, uint16_t data)
{
    uint8_t temp_h, temp_l;
    temp_h = (data & 0xFF00) >> 8;
    temp_l = data & 0x00FF;

    USART_SendData(pUSARTx, temp_h);
    while (USART_GetFlagStatus(pUSARTx,USART_FLAG_TXE) == RESET);

    USART_SendData(pUSARTx, temp_l);
    while (USART_GetFlagStatus(pUSARTx,USART_FLAG_TXE) == RESET);

}

// 发送8位数据的数组
void USART_SendArray(USART_TypeDef *pUSARTx, uint8_t *arr, uint8_t num)
{
    uint8_t i = 0;

    for ( i = 0; i < num; i++)
    {
        USART_SendByte(pUSARTx, arr[i]);
    }
    while (USART_GetFlagStatus(pUSARTx, USART_FLAG_TC) == RESET);

}

// 发送字符串
void USART_SendStr(USART_TypeDef *pUSARTx, const char *str)
{
    while (*str != '\0')
    {
        USART_SendByte(pUSARTx, *str++);
    }
        
    while (USART_GetFlagStatus(pUSARTx, USART_FLAG_TC) == RESET);

}


/*------------------------------  重定向  ------------------------------*/
// MDK中的方式
// 重定向c库函数printf到串口
/* int fputc(int ch, FILE *f)
{
    // 发送一个字节数据到串口
    USART_SendData(DEBUG_USARTx, (uint8_t)ch);

    // 等待发送完成
    while (USART_GetFlagStatus(DEBUG_USARTx, USART_FLAG_TXE) == RESET);

    return ch;
} */

// 重定向c库函数scanf到串口,scanf,getchar
/* int fgetc(FILE *f)
{
    while (USART_GetFlagStatus(DEBUG_USARTx, USART_FLAG_RXNE) == RESET)
        ;

    return (int)USART_ReceiveData(DEBUG_USARTx);
} */


/*----------- GNU gcc的方式 ----------------*/
int _write(int fd, char *ptr, int len)
{
    // // 发送一个字节数据到串口

    // USART_SendStr(DEBUG_USARTx, ptr);

    // // 等待发送完成
    // // while (USART_GetFlagStatus(DEBUG_USARTx, USART_FLAG_TXE) == RESET);

    // return len;
    // -上面的方式放回的len不对，导致有些乱码问题，还是得老老实实去遍历一下
    int i = 0;
    if (fd > 2)
    {
        return -1;
    }

    while (*ptr && (i < len))
    {
        USART_SendByte(DEBUG_USARTx, (uint8_t)*ptr);
        // if (*ptr == '\n')
        // {
        //     USART_SendByte(DEBUG_USARTx, '\r');
        // }

        i++;
        ptr++;
    }

    return i;
}

/* int _read(int fd, char *ptr, int len)
{
    int my_len;

    if (fd > 2)
    {
        return -1;
    }

    ge
} */

/*-----------------------------------------------------*/
