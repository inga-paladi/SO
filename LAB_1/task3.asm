; M3: Write character/attribute
go:
    mov AH, 02H     
    mov BH, 0       ;video page number
    mov DH, 10      ;Set Cursor Position row
    mov DL, 20      ;Set Cursor Position column
    int 10h

    mov AH, 09H     
    mov AL, 'B'     ;character to write
    mov BH, 0       ;video page number
    mov BL, 04H     ;video attribute for character 
                    ;graphics modes: color number
    mov CX, 3       ;repeat count
    int 10h