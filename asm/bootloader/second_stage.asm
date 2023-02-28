;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - second_stage.asm
; 
; Bootloader second stage. Loaded by first stage  
;---------------------------------------------------------
;*********************************************************

; FIXME: screen driver cursor and newlines
; TODO: keyboard driver
; TODO: shell interface
; TODO: Review long mode and paging

[bits 16]
call clear_screen

mov [BOOT_DRIVE], dl ; BIOS stored the current boot drive in dl, so we can save it in the BOOT_DRIVE variable

call switch_to_lm

jmp $ ; infinite loop

; include macros
%include "./asm/drivers/screen_rm/screen_rm.asm"
%include "./asm/bootloader/long_mode.asm"

[bits 64]
; the first thing we do after switching to 64-bit LONG MODE
BEGIN_LM:
	call THIRD_STAGE_OFFSET

	jmp $ ; infinite loop


; global variables
THIRD_STAGE_OFFSET equ 0x8600
BOOT_DRIVE: db 0
MSG_LONG_MODE: db "Swithced to LONG MODE.", 0
MSG_LOAD_THIRD_STAGE: db "Loading third stage into memory.", 0
MSG_LOADED_THIRD_STAGE: db "Third stage has been loaded into memory.", 0

times 2048-($-$$) db 0 ; add padding to make the second stage occupy 4 sectors