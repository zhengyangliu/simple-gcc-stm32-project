#工程的名称及最后生成文件的名字
TARGET = LED_project

#设定临时性环境变量
export CC             = arm-none-eabi-gcc           
export AS             = arm-none-eabi-as
export LD             = arm-none-eabi-ld
export OBJCOPY        = arm-none-eabi-objcopy

#读取当前工作目录
TOP=$(shell pwd)

#设定包含文件目录
INC_FLAGS= -I $(TOP)/CORE                  \
           -I $(TOP)/HARDWARE    \
           -I $(TOP)/STM32F10x_FWLib/inc             \
           -I $(TOP)/SYSTEM        \
           -I $(TOP)/USER

CFLAGS =  -W -Wall -g -mcpu=cortex-m3 -mthumb -D STM32F10X_HD -D USE_STDPERIPH_DRIVER $(INC_FLAGS) -O0 -std=gnu11
C_SRC=$(shell find ./ -name '*.c')  
C_OBJ=$(C_SRC:%.c=%.o)          

.PHONY: all clean update      

all:$(C_OBJ)
	$(CC) $(C_OBJ) -T stm32_f103ze_gcc.ld -o $(TARGET).elf   -mthumb -mcpu=cortex-m3 -Wl,--start-group -lc -lm -Wl,--end-group -specs=nano.specs -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler -Wl,-Map=Project.map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 
	$(OBJCOPY) $(TARGET).elf  $(TARGET).bin -Obinary 
	$(OBJCOPY) $(TARGET).elf  $(TARGET).hex -Oihex

$(C_OBJ):%.o:%.c
	$(CC) -c $(CFLAGS) -o $@ $<
clean:
	rm -f $(shell find ./ -name '*.o')
	rm -f $(shell find ./ -name '*.d')
	rm -f $(shell find ./ -name '*.map')
	rm -f $(shell find ./ -name '*.elf')
	rm -f $(shell find ./ -name '*.bin')
	rm -f $(shell find ./ -name '*.hex')

update:
	openocd -f /usr/share/openocd/scripts/interface/stlink-v2.cfg  -f /usr/share/openocd/scripts/target/stm32f1x_stlink.cfg -c init -c halt -c "flash write_image erase $(TOP)/LED_project.hex" -c reset -c shutdown
 


 










