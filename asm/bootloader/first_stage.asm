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

xor  ax, ax
mov  ds, ax
mov  es, ax    

mov  [BOOT_DRIVE], dl
mov  ax, 0x07E0
cli
mov  ss, ax 
mov  sp, 0x1200
sti


call clear_screen ; clear the screen because BIOS printed alotta stuff

mov bx, MSG_REAL_MODE
call print_rm

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