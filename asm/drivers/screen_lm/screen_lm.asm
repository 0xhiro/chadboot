;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - screen_lm.asm
; 
; Simple screen driver for printing text in
; 64-bit (LONG MODE) using the VGA text buffer  
;---------------------------------------------------------
;*********************************************************

[bits 64]
global a_print ; make the function globally accessible by C, Rust and other external callers
global a_set_cursor
global a_print_char

; Prints strings using the VGA text buffer [edi]
a_print:
		mov ecx , VIDEO_MEMORY

print_loop:
	mov al, [edi]
		
	cmp al, 0
	je done

	call a_print_byte
			
	add edi, 1
	add ecx, 2
	
	jmp print_loop

done:
	ret


; prints a single byte [ax]
a_print_byte:
	mov ah, DEFAULT_COLOR
	mov [ecx], ax

	ret

; sets the position of the cursor []
; offset is passed as
a_set_cursor:
	mov bx, [edi] ; input
		
	mov dx, SCREEN_CTRL
	mov al, OFFSET_LOW
	out dx, al
 
	inc dl
	mov al, bl
	out dx, al
 
	dec dl
	mov al, OFFSET_HIGH
	out dx, al
 
	inc dl
	mov al, bh
	out dx, al
	ret



; global variables
VIDEO_MEMORY equ 0xb8000
DEFAULT_COLOR equ 0x0a
MAX_ROWS equ 25
MAX_COLS equ 80
SCREEN_CTRL equ 0x3D4
SCREEN_DATA equ 0x3D5
OFFSET_LOW equ 0x0f
OFFSET_HIGH equ 0x0e