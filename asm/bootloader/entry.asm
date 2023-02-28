;*********************************************************
;---------------------------------------------------------
; CHADOS - x86 ASM - entry.asm
; 
; Ensures that we jump straight into the kernel’s
; entry function (main in kernel.c). This happens 
; because this file is linked with the kernel, but is
; placed as the first file to be linked. Therefore,
; when the kernel gets executed through it's offset
; address, the first thing that is executed is this file,
; which then calls the main function in the kernel
;---------------------------------------------------------
;*********************************************************

[bits 64] ; we are in 64-bit (LONG MODE) since this file is compiled with the kernel
[extern third_stage] ; declare an external function

third_stage_entry:
	call third_stage ; invoke the "init" function in our kernel
	
	jmp $ ; infinite loop in case we return from the kernel