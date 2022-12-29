;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - screen_rm.asm
;
; Simple driver for printing text in 16-bit REAL MODE
; using BIOS  
;---------------------------------------------------------
;*********************************************************

[bits 16]

; TODO: extend features 😀✏️
; prints strings using a BIOS routine [bx]
print_rm:
	pusha

string_loop:
	mov al, [bx]
	call print_byte
	inc bx
	
	cmp al, 0
	jne string_loop
	
	popa
	ret





; prints a single byte using a bios interrupt [al]
print_byte:
	pusha
	
	mov ah, 0x0e
	int 0x10
	
	popa
	ret




; clears all text on the screen
clear_screen:
	pusha
	
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	
	popa
	ret



; for printing raw hexadecimal values, useful for inspecting memory, e.t.c [dx]
print_hex:
	pusha

	mov cx, 4

char_loop:
	dec cx        
	mov ax,dx         
	shr dx,4          
	and ax,0xf        

	mov bx, HEX_OUT   
	add bx, 2         
	add bx, cx        

	cmp ax,0xa        
	jl set_letter     
	add byte [bx],7   
                    
	jl set_letter

set_letter:
	add byte [bx],al  

	cmp cx,0          
	je print_hex_done 
	jmp char_loop     

print_hex_done:
	mov bx, HEX_OUT   
	call print_rm

	popa              
	ret              
	


HEX_OUT: db '0x0000', 0 ; buffer string for print_hex output 
