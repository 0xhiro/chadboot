# VARIABLES
#*********************************************************

b = load_second_stage

#*********************************************************



# RUNNERS
#*********************************************************

all: ./target/chadboot.bin

clean:
	rm -fr target/*.bin target/*.elf target/*.dis target/*.o target/*.img target/*.map target/*.a

run: all
	qemu-system-x86_64 -drive file=./target/chadboot.bin,format=raw,index=0,media=disk --no-reboot --no-shutdown -d int -M smm=off -s

debug: all 
	qemu-system-x86_64 -D ./qemu.logs -drive file=./target/chadboot.bin,format=raw,index=0,media=disk --no-reboot --no-shutdown -d int -M smm=off -S -s &
	clear
	make qemu-logs 
	
gdb:
	gdb -q -x ./gdb.conf -ex 'b $(b)'

size:
	ls  -lah ./target/ | awk '{print $$9, $$5}' | grep -E '.bin|.img'

qemu-logs:
	tail -f qemu.logs

#*********************************************************


# MERGE STAGES
#*********************************************************

./target/chadboot.bin: ./target/first_stage.bin ./target/second_stage.bin
	cat $^ > $@

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
