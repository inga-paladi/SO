; M2: Write character
go:
    mov AH, 0aH     
    mov AL, 'A'     ;character to write
    mov BH, 0       ;video page number
    mov CX, 5       ;repeat count
    int 10h
