; Jan-12-14
; rkenny
;
; Echoes a user's input, up to 255 bytes
; exits when user inputs 'exit'
;
; compile using nasm on Linux

section .text
  global main

main:
    mov edx, welcomeL    ; edx is the number of characters to print
    mov ecx, welcome     ; ecx points to the address of the string to print
    mov ebx, 1          ; stdout is file #1
    mov eax, 4          ; syscall 4 is write
    int 80h
    
promptForInput:    
    mov edx, promptL
    mov ecx, prompt
    mov ebx, 1
    mov eax, 4          ;write the prompt
    int 80h
    
    mov edi, 0
getInput:
    mov esi, userInput      ;read 1 byte into 'userInput'
    mov eax, 3  
    mov ebx, 1  
    mov ecx, esi            ;use esi because we're doing more work with userInput
    mov edx, 1  
    int 0x80
    
    mov al, [esi]           ;ues al to compare

    cmp al, 0x61            ;ASCII codes >61 are lower case
    jl skipUppercasing      
    sub byte [esi], 0x20    ;subtract 0x20 to convert to upper case
skipUppercasing:

    mov eax,[userInput]     ;if the user hit enter, echo their input
    cmp al, 0xA
    je printInput

storeInput:                 ;otherwise, continue adding their input to storedString
    mov [storedString+edi], eax 
    inc edi
    jmp getInput            ;get the next character

 printInput:                ; the user hit enter. Output their input
    mov eax, 4
    mov ebx, 1
    mov ecx, storedString
    mov edx, edi            ; up to 255 bytes. Buffer overflow.
    int 0x80
    
    mov esi, storedString
    mov edi, exitCommand
    mov ecx, exitCommandL
    cld
    repe cmpsb
    jecxz exit              ; compare to exitCommand string. If it doesn't match, get more input
    jmp promptForInput
    
;;;; This exits with a return code of 0
exit:
    mov	eax, 1
    mov ebx, 0
    int 80h
  
  
section .data
    welcome: db "CMD 0.1a",10,0
    welcomeL: equ $-welcome
    prompt: db 10,"> ",0
    promptL: equ $-prompt

    exitCommand: db "EXIT",0
    exitCommandL: equ $-exitCommand

section .bss
    userInput:  resb 8
    storedString: resb 255
