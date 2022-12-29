;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - first_stage.asm
;
; Bootloader entry, first file to be executed. 
; This is where we hijack the computer from BIOS.
; We are loaded into 16-bit REAL MODE at 0x7c00
;---------------------------------------------------------
;*********************************************************

global _start
_start: ; we start in 16-bit REAL MODE


[bits 16]
mov bp, 0x90000 ; Initialize our stack at 0x9000, far from our code
mov sp, bp

call clear_screen ; clear the screen because BIOS printed alotta stuff

mov bx, MSG_REAL_MODE
call print_rm

mov [BOOT_DRIVE], dl ; BIOS stored the current boot drive in dl, so we can save it in the BOOT_DRIVE variable

call load_second_stage

mov dl, [BOOT_DRIVE] ; restore boot drive to dl

call SECOND_STAGE_OFFSET ; finally, give control to the second stage

jmp $ ; infinite loop

; include macros
%include "./asm/drivers/disk_rm/disk_rm.asm"
%include "./asm/drivers/screen_rm/screen_rm.asm"

[bits 16]
; load the second stage from disk into memory
load_second_stage:
	mov bx, MSG_LOAD_SECOND_STAGE
	call print_rm

	mov bx, SECOND_STAGE_OFFSET ; bx tells BIOS where to load the data into
	mov cl, 0x02 ; cl tells BIOS which sector to start from, kinda like an offset. Here we say start from the second sector, which is the sector after the boot sector (coincidentally, we placed our kernel right there)
	mov dh, 3 ; we are reading 3 sectors
	mov dl, [BOOT_DRIVE] ; dl tells BIOS which particular disk to read from
	call read_disk

	mov bx, MSG_LOADED_SECOND_STAGE
	call print_rm

	ret



; Declare global variables
SECOND_STAGE_OFFSET equ 0x7e00
BOOT_DRIVE: db 0
MSG_REAL_MODE: db "Started in 16-bit Real Mode.", 0
MSG_LOAD_SECOND_STAGE: db "Loading second stage into memory.", 0
MSG_LOADED_SECOND_STAGE: db "second stage has been loaded into memory.", 0

times 510-($ - $$) db 0 ; padding with zeros for our boot sector
dw 0xaa55 ; our BIOS boot sector magic number