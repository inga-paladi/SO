;M4: Display character + attribute
org 7c00H ;
    
mov BH, 0       ;Clears the BH register            
mov AX, 0H      ;Clears the AX register
mov ES, AX      ;Initializes the Extra Segment register with 0          
mov BP, msg     ;Loads the offset address of the msg string into the BP register
             
mov AL, 1  
mov CX, 6                
mov DH, 1                
mov DL, DH                

mov AX, 1302H
int 10H

jmp $                    

msg db 'H', 19H, 'e', 1aH, 'l', 19H, 'l', 1cH, 'o', 19H