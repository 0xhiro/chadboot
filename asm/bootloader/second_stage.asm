;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - second_stage.asm
; 
; Bootloader second stage. Loaded by first stage  
;---------------------------------------------------------
;*********************************************************


[bits 16]
call clear_screen

mov bx, MSG_GOT_CONTROL
call print_rm

; call clear_screen

mov [BOOT_DRIVE], dl ; BIOS stored the current boot drive in dl, so we can save it in the BOOT_DRIVE variable

; call load_kernel ; load the kernel ahead of time because we can't use BIOS in 64-bit LONG MODE

; call clear_screen

; call switch_to_lm ; switch to 64-bit LONG MODE

jmp $ ; infinite loop

; include macros
%include "./asm/drivers/screen_lm/screen_lm.asm"
%include "./asm/drivers/disk_rm/disk_rm.asm"
%include "./asm/drivers/screen_rm/screen_rm.asm"
%include "./asm/bootloader/long_mode.asm"

[bits 16]
; loads the kernel from disk into memory (at KERNEL_OFFSET)
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print_rm

	mov bx, KERNEL_OFFSET ; bx tells BIOS where to load the data into
	mov dh, 10 ; we are reading 15 sectors
	mov cl, 0x05 ; cl tells BIOS which sector to start from,
	mov dl, [BOOT_DRIVE] ; dl tells BIOS which particular disk to read from
	call read_disk

	mov bx, MSG_LOADED_KERNEL
	call print_rm

	ret



[bits 64]
; the first thing we do after switching to 64-bit LONG MODE
BEGIN_LM
	;mov edi, MSG_LONG_MODE
	;call a_print

	call KERNEL_OFFSET
	
	jmp $ ; infinite loop


; global variables
KERNEL_OFFSET equ 0x8e00 
BOOT_DRIVE: db 0
MSG_GOT_CONTROL: db "Second stage has taken control, MEKO", 0
MSG_PROT_MODE: db "Successfully landed in 32-bit Protected Mode.", 0
MSG_LONG_MODE: db "NOW IN LONG MODE!", 0
MSG_LOAD_KERNEL: db "Loading kernel into memory.", 0
MSG_LOADED_KERNEL: db "Kernel has been loaded into memory.", 0

times 1024 db 0 ; add padding to make the second stage occupy at least 3 sectors