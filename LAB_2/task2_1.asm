org 7c00h                 ; Set the origin address of the bootloader to 7C00h

; Initialize SI register to point to the buffer
mov si, buffer

; Main loop to read and display characters
write_chr:
    mov ah, 0              ; Set AH register to 0 (function 0 of int 16h - BIOS keyboard input)
    int 16h                ; Call BIOS keyboard input

    cmp ah, 0eh            ; Compare AH to 0x0E (Backspace keypress)
    je press_backspace     ; Jump to the press_backspace label if equal

    cmp ah, 1ch            ; Compare AH to 0x1C (Enter keypress)
    je press_enter         ; Jump to the press_enter label if equal

    cmp si, buffer + 256   ; Compare SI to the end of the buffer (256 bytes)
    je write_chr           ; Jump back to write_chr if the buffer is full

    mov [si], al           ; Store the input character in the buffer
    add si, 1              ; Increment SI to point to the next buffer location

    mov ah, 0eh            ; Set AH to 0x0E (function 0Eh of int 10h - BIOS video output)
    int 10h                ; Call BIOS video output to display the character

    jmp write_chr          ; Repeat the main loop

; Handle backspace keypress
press_backspace:
    cmp si, buffer         ; Compare SI to the start of the buffer
    je write_chr           ; Jump back to write_chr if SI is at the beginning of the buffer

    sub si, 1              ; Decrement SI to point to the previous buffer location
    mov byte [si], 0      ; Set the character in the buffer to 0 (erase it)

    mov ah, 03h            ; Set AH to 03h (function 03h of int 10h - BIOS video cursor position)
    mov bh, 0              ; Set BH to 0 (video page)
    int 10h                ; Call BIOS video cursor position to move the cursor back

    cmp dl, 0              ; Compare DL (column position) to 0
    jz previous_line       ; Jump to the previous_line label if DL is 0 (wrap to the previous line)
    jmp write_space        ; Jump to write_space to handle scrolling and clearing the line

; Scroll the screen when needed
write_space:
    mov ah, 02h            ; Set AH to 02h (function 02h of int 10h - BIOS video scroll up)
    sub dl, 1              ; Decrement DL (column position)
    int 10h                ; Call BIOS video scroll up to scroll the screen up by one line

    mov ah, 0ah            ; Set AH to 0ah (function 0ah of int 10h - BIOS video attribute)
    mov al, 20h            ; Set AL to 20h (space character)
    mov cx, 1              ; Set CX to 1 (number of spaces to write)
    int 10h                ; Call BIOS video attribute to write a space character

    jmp write_chr          ; Continue with the main loop

; Move to the previous line
previous_line:
    mov ah, 02h            ; Set AH to 02h (function 02h of int 10h - BIOS video set cursor position)
    mov dl, 79             ; Set DL to 79 (position in the last column)
    sub dh, 1              ; Decrement DH (row position) to move to the previous line
    int 10h                ; Call BIOS video set cursor position to move the cursor up

; Handle Enter keypress
press_enter:
    mov ah, 03h            ; Set AH to 03h (function 03h of int 10h - BIOS video cursor position)
    mov bh, 0              ; Set BH to 0 (video page)
    int 10h                ; Call BIOS video cursor position to move the cursor down

    sub si, buffer         ; Subtract the buffer address from SI to calculate the length of the input string

    jz move_curs_down      ; Jump to move_curs_down if the input string is empty

    cmp dh, 24             ; Compare DH (row position) to 24
    jl print_word          ; Jump to print_word if DH is less than 24 (room to print the word)

    mov ah, 06h            ; Set AH to 06h (function 06h of int 10h - BIOS scroll window up)
    mov al, 1              ; Set AL to 1 (number of lines to scroll)
    mov bh, 07h            ; Set BH to 07h (attribute for the new lines)
    mov cx, 0              ; Set CX to 0 (upper left corner position)
    mov dx, 184fh          ; Set DX to 184Fh (lower right corner position)
    int 10h                ; Call BIOS scroll window up to create a new line at the bottom
    mov dh, 17h            ; Set DH to 17h (move the cursor to the new line)

; Print the word on the screen
print_word:
    mov bh, 0              ; Set BH to 0 (video page)
    mov ax, 0              ; Set AX to 0 (used for setting the ES register)
    mov es, ax             ; Set ES to 0 (segment of the video buffer)
    mov bp, buffer         ; Set BP to the address of the buffer

    mov bl, 07h            ; Set BL to 07h (character attribute)
    mov cx, si             ; Set CX to the length of the input string
    add dh, 1              ; Increment DH (row position) to move below the previous line
    mov dl, 0              ; Set DL to 0 (column position)

    mov ax, 1301h          ; Set AX to 1301h (function 1301h of int 10h - BIOS write character and attribute)
    int 10h                ; Call BIOS write character and attribute to display the input string

; Move the cursor down
move_curs_down:
    mov ah, 03h            ; Set AH to 03h (function 03h of int 10h - BIOS video cursor position)
    mov bh, 0              ; Set BH to 0 (video page)
    int 10h                ; Call BIOS video cursor position to move the cursor down

    mov ah, 02h            ; Set AH to 02h (function 02h of int 10h - BIOS video set cursor position)
    mov bh, 0              ; Set BH to 0 (video page)
    add dh, 1              ; Increment DH (row position) to move down one line
    mov dl, 0              ; Set DL to 0 (column position)
    int 10h                ; Call BIOS video set cursor position to move the cursor down

    add si, buffer         ; Add the buffer length to SI to prepare for the next input

; Clear the buffer
clear_buffer:
    mov byte [si], 0       ; Set the current buffer location to 0 (clear it)
    add si, 1              ; Increment SI to move to the next buffer location

    cmp si, buffer + 256   ; Compare SI to the end of the buffer
    jne clear_buffer       ; Repeat the buffer clearing loop if SI is not at the end of the buffer

    mov si, buffer          ; Reset SI to the start of the buffer
    jmp write_chr          ; Continue with the main loop

; Define constants and variables
buffer: times 256 db 0h    ; Define a 256-byte buffer for storing input characters
