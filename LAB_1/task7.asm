;M7: DiSpLAy String & upDAtE CurSor
org 7C00H
    
mov BH, 0                 
mov AX, 0H
mov ES, AX                 
mov Bp, msg   

mov BL, 57H                
mov AL, 1                
mov CX, 12               
mov DH, 1                
mov DL, DH                

mov AX, 1301H
int 10H

jmp $                   

msg DD "HELLO WORLD!"
    