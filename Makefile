ASM = nasm
LD = ld

CC = gcc
#CFLAGS = -Wall -Wextra -std=c11 -O2 -g -mavx2
CFLAGS = -O2 -mavx2 -std=gnu17
INCLUDES = -Isrc
LDFLAGS = -lm -lX11 -lpng

SRC_DIR = src
BUILD_DIR = build
CODE_DIR = code

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

.PHONY: Floppy Kernel Bootloader

Floppy: $(BUILD_DIR)/Floppy.img

$(BUILD_DIR)/Floppy.img: Bootloader Kernel always
	dd if=/dev/zero of=$(BUILD_DIR)/Floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/Floppy.img
	dd if=$(BUILD_DIR)/Bootloader.bin of=$(BUILD_DIR)/Floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/Floppy.img $(BUILD_DIR)/Kernel.bin "::kernel.bin"

Bootloader: $(BUILD_DIR)/Bootloader.bin

$(BUILD_DIR)/Bootloader.bin: always
	$(ASM) ./$(SRC_DIR)/bootloader/Main.asm -o ./$(BUILD_DIR)/Bootloader.bin

Bootloader: $(BUILD_DIR)/Kernel.bin

$(BUILD_DIR)/Kernel.bin: always
	$(ASM) ./$(SRC_DIR)/kernel/Main.asm -o ./$(BUILD_DIR)/Kernel.bin

always:
	mkdir -p $(BUILD_DIR)

all: Floppy
	
#$(LD) ./$(SRC_DIR)/Boot.bin -o ./$(BUILD_DIR)/Boot
#$(CC) $(CFLAGS) $(INCLUDES) ./$(SRC_DIR)/Main.c -o ./$(BUILD_DIR)/Main $(LDFLAGS) 

exe:
	qemu-system-i386 -fda ./$(BUILD_DIR)/Floppy.img
#./$(BUILD_DIR)/Boot

clean:
	rm -rf $(BUILD_DIR)/*

do: clean all exe