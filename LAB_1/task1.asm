; Method1: Write character as TTY
go:
    mov AH, 0eh
    mov AL, 'A'     ;character to write
    mov BL, 04H     ;video page number
    int 10h         ;repeat count
    
