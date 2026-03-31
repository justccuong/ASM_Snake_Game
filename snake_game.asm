.model small
.stack 100h

.data

    curr_dir DB 4Dh   
    x_pos DW 10
    y_pos DW 10   
  
    food_x DW 0
    food_y DW 0

    snake_len DW 1
    snake_pos DW 2000 dup(0)  
    
    msg_g_over DB "Game Over!$"

.code
main proc
    mov ax,@Data
    mov ds,ax        
    
    mov ah,00h
    mov al,13h
    int 10h
    
    mov ax,0A000h
    mov es, ax   
    
    mov di,3210     
    mov al, 02h 
    mov es:[di],al  
    
    mov snake_pos[0], di ; luu vi tri dau tien vao mang luc khoi dong
    
    call create_food
    
    game_loop:   
        mov ah,01h      
        int 16h
        jz keep_moving  
            
        mov ah,00h
        int 16h
    
    check_left:
        cmp ah, 4Bh
        jne check_right
        cmp curr_dir, 4Dh 
        je keep_moving
        jmp accept_key
        
    check_right:
        cmp ah, 4Dh
        jne check_up
        cmp curr_dir, 4Bh
        je keep_moving
        jmp accept_key
        
    check_up:
        cmp ah, 48h
        jne check_down
        cmp curr_dir, 50h
        je keep_moving
        jmp accept_key
    
    check_down: 
        cmp ah, 50h
        jne keep_moving
        cmp curr_dir, 48h
        je keep_moving    
    
    accept_key:    
        mov curr_dir, ah
    
    keep_moving:
        cmp curr_dir,48h
        je move_up
        cmp curr_dir,50h
        je move_down
        cmp curr_dir,4Bh
        je move_left
        cmp curr_dir,4Dh
        je move_right

    move_down:    
        add y_pos,1
        cmp y_pos,200
        jge game_over
        mov ax, di
        add ax, 320
        jmp check_collision 
        
    move_up:  
        sub y_pos,1
        cmp y_pos,0
        jl game_over
        mov ax, di
        sub ax, 320
        jmp check_collision
        
    move_right:
        add x_pos,1
        cmp x_pos,320
        jge game_over
        mov ax, di
        add ax, 1
        jmp check_collision
        
    move_left:
        sub x_pos,1
        cmp x_pos,0
        jl game_over
        mov ax, di
        sub ax, 1
        ; chay tuot xuong check_collision luon

    check_collision:
        mov bx, ax
        mov bl, es:[bx]
        cmp bl, 02h      ; dam vao than?
        je game_over
        cmp bl, 04h      ; thay moi?
        je eat
        
        ; neu di binh thuong: xoa duoi cu
        mov bx, snake_len
        dec bx
        shl bx, 1
        mov bx, snake_pos[bx]
        mov byte ptr es:[bx], 00h
        
        call shift_body
        
        ; ve dau moi va cap nhat mang
        mov di, ax
        mov al, 02h
        mov es:[di], al
        mov snake_pos[0], di
        
        jmp frame_delay
        
    ; --- LOGIC AN MOI ---
    eat:
        add snake_len, 1     ; beo len 1 dot!
        call shift_body      ; keo than di theo
        
        mov di, ax           ; chuyen den vi tri cuc moi
        mov al, 02h          ; nuot moi (ve mau xanh de len)
        mov es:[di], al
        mov snake_pos[0], di ; cap nhat mang
        
        call create_food     ; tao moi moi
        jmp frame_delay
        
    frame_delay:
        mov cx, 0FFFFh
        delay_time:
            loop delay_time 
        jmp game_loop
                       
    ; --- HAM CON DICH CHUYEN MANG ---
    shift_body: 
        push cx  
        push ax
        
        mov cx, snake_len
        sub cx, 1
        jz skip_shift     
        
        mov bx, cx                   
        shl bx, 1   
        
    shift_loop:
        mov ax, snake_pos[bx - 2]
        mov snake_pos[bx], ax
        sub bx, 2
        loop shift_loop      ; sua loi cu phap roi nhe do ngoc
    
    skip_shift:
        pop ax
        pop cx
        ret                
                       
    ; --- HAM CON TAO MOI ---
    create_food: 
        push di 
        
    randomize:
        mov ah,00h
        int 1Ah
        mov ax,dx
        
        xor dx,dx
        mov bx,320
        div bx
        mov food_x, dx
        
        mov ah,00h
        int 1Ah
        mov ax,dx
        
        xor dx,dx
        mov bx,200
        div bx
        mov food_y, dx  
        
        mov ax,food_y
        mov bx,320
        mul bx
        add ax,food_x
        
        mov di,ax
        
        mov bl, es:[di]
        cmp bl, 02h
        je randomize
        
        mov al,04h
        mov es:[di],al        
        
        pop di
        ret
    
    game_over:
        mov ah, 00h
        mov al, 03h
        int 10h
        
        lea dx,msg_g_over
        mov ah,9
        int 21h
        
        mov ah, 4Ch
        int 21h
main endp
end main