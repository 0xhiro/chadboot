;*********************************************************
;---------------------------------------------------------
; CHADBOOT - x86 ASM - disk_rm.asm
;
; low level abstractions for disk/storage 
; I/O in 16-bits REAL MODE.  
; Contains functions for loading data likethe second
; bootloader stage from disk
;---------------------------------------------------------
;*********************************************************

[bits 16]

dap: 				db 16   ; size of dap
					db 0    ; reserved
	.num_blocks:    db 5    ; number of blocks to transfer
    				db 0    ; reserved
	.buffer_addr:   dd 0x7e00    ; seg:offset of transfer buffer
	.start_lba:     dq 2    ; start lba of transfer



; reads data from disk using a BIOS interrupt [bx, cl, dh, dl]
read_disk:
	push dx ; save dx in the stack so that after this read operation, we can compare to see how many sectors were actually read
	
	mov dl, [BOOT_DRIVE] ; dl tells BIOS which particular disk to read from
	mov ah, 0x42 ; tells BIOS that this is a disk read function
	mov si, dap
	
	int 0x13 ; the interrupt that actually triggers the BIOS routine

	jc disk_error ; jump to disk_error if an error occured

	pop dx ; now grab back the value of dx from the stack (that we pushed earlier)
	cmp dh, al ; compare the number of sectors read (BIOS saved in al) with the number of sectors we wanted to read
	;jne disk_error ; jump to disk_error if they were not equal
	
	ret

; well, you gotta handle errors too!
disk_error:
	mov bx, DISK_ERROR_MSG
	call print_rm
	jmp $ ; unfortunately, we're simply doing an infinite loop (:



DISK_ERROR_MSG: db 'Disk read error', 0