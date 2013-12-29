section .text
global _start

;;;; Prints hi world, then takes an 8 character input.

;;; Param: string
;;; returns the length of the string as a byte
strlen:
  push ebp	; save ebp
  mov ebp, esp 	; use ebp as a stack reference
  ; save registers
  ;push eax
  push ecx
  push edi
 ; begin function
 ;; parameters are at esp+(16)

  sub eax, eax	; scasb looks for the value in 
  sub ecx, ecx	; ecx is used as a counter
  not ecx	;
  cld		; count down as the code iterates through the string
  mov edi, [esp+16] 	; edi points to the target string
  repne scasb   ; while edi != al, move up, increment ecx

  not ecx	; ecx is the 2s compliment of the length
  dec ecx	; so convert it to the real length, dec ecx to remove the nul from len
  mov eax, ecx

  ;mov esp, ebp	; restore ebp
 ;push ecx	; return the of length the string  
 ;mov edi, ecx
 
  ; restore stack
  pop edi
  pop ecx
  ;pop eax
  pop ebp

  ret 0004	; unpop msg
;--- end strlen

;;---
;; str read
;
; params: the buffer to read into
;
strread:
  push ebp
  mov ebp, esp
  push eax
  push ebx
  push ecx
  push edx

  ;; the string is referenced in esp+24. We need to clear its value to 0s before writing to it.
  mov edx, 24
  mov eax, [esp+edx]
  mov edx, 0
clearString:    
  mov byte [eax+edx], 0  
  inc edx
  cmp byte [eax+edx], 0
  jnz clearString

  ;; This performs the read syscall
  mov eax, 3 ; 3 is nr_read
  mov ebx, 0 ; 0 is stdin
  mov ecx, [esp+24] ; read 8 characters
  mov edx, 8
  int 80h

  pop edx
  pop ecx
  pop ebx
  pop eax
  pop ebp
  ret 0004
;--- end str read



_start:
  push msg	; msg is the only parameter for strlen
  call strlen
  mov edx, eax	;edx stores the length of the string, returned in eax, for sys_write

;; print hello world

  mov ebx, 1	; ebx defines the file descriptor to print to
  mov eax, 4	;  defines the syscall (4 is sys_write)
  mov ecx, msg	; ecx stores the pointer to the beginning of the string
  int 0x80

  push msg
  call strread
  
  push msg
  call strlen
  mov edx, eax

  mov ebx, 1	; ebx defines the file descriptor to print to
  mov eax, 4	;  defines the syscall (4 is sys_write)
  mov ecx, msg	; ecx stores the pointer to the beginning of the string
  int 0x80


  mov eax, 1	; (sys_exit)
  int 0x80


section .data

  msg db 'Hello, world!',0xa, 0
