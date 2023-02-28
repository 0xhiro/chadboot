# VARIABLES
#*********************************************************


#*********************************************************



# RUNNERS
#*********************************************************

all: ./target/chadboot.bin

clean:
	rm -fr target/*.bin target/*.elf target/*.dis target/*.o target/*.img target/*.map target/*.a

run: all
	qemu-system-x86_64 -drive file=./target/chadboot.bin,format=raw,index=0,media=disk --no-reboot --no-shutdown -d int -M smm=off -s

debug: all 
	make clean
	make all
	qemu-system-x86_64 -D ./qemu.logs -drive file=./target/chadboot.bin,format=raw,index=0,media=disk --no-reboot --no-shutdown -d int -M smm=off -S -s &
	make qemu-logs 
	
gdb:
	gdb -q -x ./gdb.conf 

size:
	ls  -lah ./target/ | awk '{print $$9, $$5}' | grep -E '.bin|.img'

qemu-logs:
	tail -f qemu.logs

#*********************************************************


# MERGE STAGES
#*********************************************************

./target/chadboot.bin: ./target/first_stage.bin ./target/second_stage.bin ./target/third_stage.bin ./zero.bin
	cat $^ > $@

#*********************************************************


# THIRD STAGE BOOTLOADER
#*********************************************************

./target/c_screen.o: ./c/drivers/screen/screen.c 
	gcc -ffreestanding -masm=intel -gdwarf -c $< -o $@

./target/c_serial.o: ./c/bootloader/serial.c
	gcc -ffreestanding -masm=intel -gdwarf -c $< -o $@

./target/c_mem.o: ./c/bootloader/mem.c
	gcc -ffreestanding -masm=intel -gdwarf -c $< -o $@

./target/third_stage.o: ./c/bootloader/third_stage.c
	gcc -ffreestanding -masm=intel -gdwarf -c $< -o $@

./target/entry.o: ./asm/bootloader/entry.asm
	nasm -F dwarf $< -f elf64 -g -o $@

./target/third_stage.elf: ./target/entry.o ./target/third_stage.o ./target/c_screen.o ./target/c_serial.o ./target/c_mem.o 
	ld -o $@ -m elf_x86_64 -Ttext 0x8600 $^

./target/third_stage.bin: ./target/third_stage.elf
	objcopy -O binary $<	$@

#*********************************************************


# SECOND STAGE BOOTLOADER
#*********************************************************

./target/second_stage.o: ./asm/bootloader/second_stage.asm
	nasm -F dwarf $< -f elf -g -o $@

./target/second_stage.elf: ./target/second_stage.o
	ld -o $@ -m elf_i386 -Ttext 0x7e00 $^
# First stage loads us at 0x7e00

./target/second_stage.bin: ./target/second_stage.elf
	objcopy -O binary $<	$@
	
#*********************************************************


# FIRST STAGE BOOTLOADER
#*********************************************************

./target/first_stage.o: ./asm/bootloader/first_stage.asm
	nasm -F dwarf $< -f elf -g -o $@

./target/first_stage.elf: ./target/first_stage.o
	ld -o $@ -m elf_i386 -Ttext 0x7c00 $^
# BIOS loads us at 0x7c00 so might as well set the offset to 0x7c00

./target/first_stage.bin: ./target/first_stage.elf
	objcopy -O binary $<	$@

#*********************************************************
