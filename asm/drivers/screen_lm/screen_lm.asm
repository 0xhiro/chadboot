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
global a_print_char

; Prints strings using the VGA text buffer [edi]
a_print:
	mov ecx , VIDEO_MEM

print_loop:
	mov al, [edi]
		
	cmp al, 0
	je done

	
	mov ah, DEFAULT_COLOR
	mov [ecx], ax

			
	add edi, 1
	add ecx, 2
	
	jmp print_loop

done:
	ret


; gets the position of the cursor > ax
a_get_cursor:
	mov dx, SCREEN_CTRL
	mov al, OFFSET_HIGH
	out dx, al
 
	mov dx, SCREEN_DATA
	in ax, dx

 	push ax
	mov dx, SCREEN_CTRL
	mov al, OFFSET_LOW
	out dx, al
	pop ax

	mov cx, ax
	mov dx, SCREEN_DATA
	in ax, dx
	add ax, cx
	
	ret


; sets the position of the cursor [ebx]
; offset is passed as bx
a_set_cursor:
	mov dx, SCREEN_CTRL
	mov al, OFFSET_HIGH
	out dx, al
 
	mov dx, SCREEN_DATA
	mov ax, bx
	shr al, 8
	out dx, al
 
	mov dx, SCREEN_CTRL
	mov al, OFFSET_LOW
	out dx, al


	mov dx, SCREEN_DATA
	mov ax, bx
	and al, 0xff
	out dx, al
	ret



; global variables
VIDEO_MEM equ 0xb8000
DEFAULT_COLOR equ 0x0a
MAX_ROWS equ 25
MAX_COLS equ 80
SCREEN_CTRL equ 0x3D4
SCREEN_DATA equ 0x3D5
OFFSET_LOW equ 0x0f
OFFSET_HIGH equ 0x0e