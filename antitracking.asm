.386

data segment use16
    STSIZE EQU 14
    tips db 'Enter the password: $'
    enterName db 0Ah, 0Dh, 'Please enter student name: $'
    inputBuf db 11, ?, 11 dup(0)
    pass db 'GoodJob!'
    jmpTable dw ?
    POIN dw ?
    gradeStr db 'Grade:$'
    scoreStr db 'Score:$'
    notFound db 0Ah, 0Dh, 'Student Not Found!$'
    nextLine db 0Ah, 0Dh, '$'
    ;xor 'D'
    buf db 62,44,37,42,35,55,37,42, 0, 0, 108,115,121, ?    ;zhangsan 40, 55, 61
        db 40,45,55,45, 6 dup(0), 20,32,2, ?            ;lisi    80, 100, 70
        db 46,45,37,51,38, 5 dup(0), 19,38,39, ?        ;jiawb  87,98,99
data ends

stack segment use16 STACK
    db 200h dup(0)
stack ends

code segment use16
assume cs:code, ds:data, ss:stack
old_int0 dw 0, 0
old_int1 dw 0, 0
envBlock dw ?, ?, ?, ?
progName db 3 dup(?)
start:    
    xor si, si
    mov ax, ds:[2ch]
    mov envBlock, ax
    mov es, ax
    
    mov ax, 'C'
    mov ds, ax
    push cx
    push di
    push bx
    push si
    push dx
    push ds
    
    mov ax, data
    mov ds, ax
    
    xor ax, ax
    xor edi, edi
    cld
    mov cx, 0fffh
    rescan:
        repnz scasb
        scasb
    jnz rescan
    
    add di, 2
    mov ax, '.'
    cld
    mov cx, 0fffh
    scanName:
        inc di
        repnz scasb
        cmp byte ptr es:[di], 'E'
    jnz scanName
    std
    dec di
    mov envBlock + 4, di        ;此位置之前为程序名称
    mov al, '\'
    mov cx, 0fffh
    repnz scasb
    inc di
    mov envBlock + 2, di        ;此位置之后为程序名称
    
    mov es, si
    
    mov bx, es:[4]
    mov cs:old_int1, bx                ;保存并修改0和1号中断的中断服务程序
    mov bx, es:[6]
    mov cs:old_int1 + 2, bx
    mov bx, es:[0]
    mov cs:old_int0, bx
    mov bx, es:[2]
    mov cs:old_int0 + 2, bx
    
    mov es:[4], offset halfexit
    mov es:[6], cs
    mov es:[0], offset newInt
    mov es:[2], cs
    
    mov ax, envBlock
    mov es, ax
    movzx ebx, word ptr envBlock + 2
    inc ebx
    mov ecx, 0
    loopXr:
        movzx ax, byte ptr es:[ebx]
        mov progName[ecx], al
        xor si, ax
        inc ebx
        inc ecx
        cmp bx, envBlock + 4
    jna loopXr                        ;根据程序名称得到si，若si不为0，程序无法执行
    
    mov word ptr jmpTable, offset L0 + 100h
    
    lea dx, tips
    mov ah, 9h
    int 21h
    
    lea dx, inputBuf
    mov ah, 10
    int 21h
    
    
    add esp, 12
    
    mov bx, 10
    mov ax, bx
    mov dx, 0
    div si

    ;si不为0，执行下面代码
    cmp byte ptr inputBuf + 1, 8
    jne halfexit
    mov ecx, 8
    lea ebx, inputBuf + 2
    lea edx, pass
    L0:
        dec ecx
        mov al, [ebx + ecx]
        cmp [edx + ecx], al
        jne halfexit
        cmp ecx, 0
    jne L0
    mov bx, jmpTable
    jmp bx

db 53,52,176,218,163,77,128,102,61,176
db 236,191,152,156,154,177,235,231,75,223
db 216,59,138,63,211,244,95,54,36,42
db 132,223,76,131,165,234,88,103,71,134
db 84,21,36,70,250,195,186,137,203,214
db 110,59,32,58,77,121,123,6,114,4
db 22,227,167,253,239,108,145,205,232,241
db 53,203,160,97,15,238,47,64,122,168
db 230,226,203,53,177,111,176,248,74,60
db 82,190,210,154,67,230,146,57,54,100
db 85,11,142,144,57,240,60,180,107,145
db 121,207,153,27,91,127,151,220,211,9
db 127,243,132,110,216,111,145,14,249,183
db 196,48,178,149,199,144,8,34,171,179
db 120,123,137,38,19,140,12,112,110,199
db 134,88,175,143,134,195,59,201,126,203

    password db 32, 51, 25, 30, 90, 94        ;密码:JYst04 xor 'j'
    
    db 70,239,84,137,128,108,55,216,32,125
    db 91,236,194,55,6,51,63,249,33,4
    db 121,144,53,214,153,143,15,218,22,212
    db 158,103,168,43,212,126,30,242,118,79
    db 29,221,65,111,200,149,199,191,103,213
    db 104,43,234,224,199,62,135,85,33,63
    
    nextCode: db 0aah, 0fdh, 43h            ;jmp contExe xor 'C'
    
db 191,28,122,77,252,88,19,12,179,178
db 139,143,221,11,14,170,97,222,221,158
db 133,114,162,219,10,27,216,57,68,122
db 239,39,103,189,224,127,209,49,56,120
db 149,202,220,94,18,100,147,19,69,91
db 138,3,59,73,234,135,191,137,46,97
db 183,60,79,74,188,122,132,75,107,130
db 23,78,4,232,144,153,59,47,77,180

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jmp exit
    
db 126,105,162,148,131,70,239,133,170,114
db 99,162,185,41,238,128,4,105,78,103
db 115,1,209,151,0,34,77,252,228,214
db 38,162,152,47,18,250,198,229,120,207
db 77,236,20,238,137,159,186,228,240,2
db 233,221,68,196,136,1,77,136,110,84
db 6,10,46,0,18,181,47,13,102,206
db 8,96,20,157,56,31,119,226,171,187
db 97,250,162,68,240,225,232,213,158,150
db 254,41,71,144,148,51,184,174,4,78


    contExe:
    mov ax, data
    mov ds, ax
    mov dl, 0Dh
    mov ah, 2
    int 21h
    mov dl, 0Ah
    mov ah, 2
    int 21h

func1:
    lea dx, enterName
    mov ah, 9
    int 21h
    lea dx, inputBuf
    mov ah, 10
    int 21h
    
    lea esi, inputBuf
    cmp  byte ptr [esi + 1], 0
    jz func1            ;输入回车
    cmp byte ptr [esi + 1], 1
    jne func2
    cmp  byte ptr [esi + 2], 'q'
    jz exit
    
    func2:
    lea ebx, buf            ;ebx:当前结构体首地址
    mov ax, 0                ;结构体索引
    lea esi, inputBuf        ;输入的姓名
    loopst:
        movzx ecx, byte ptr 1[esi]    ;输入姓名的长度
        cmp ecx, 10                ;字符串长度为10则直接比较字符串
        je cmpstr
        cmp byte ptr [ebx + ecx], 0
        jne contloopst            ;字符串长度不同

        cmpstr:
            mov dl, byte ptr [ebx + ecx - 1]    ;取当前结构体的第ecx个字符
            xor dl, progName                    ;程序名的第一个字符应当为'D'
            cmp dl, byte ptr [esi + ecx + 1]    ;与in_name的第ecx个字符比较
            jne contloopst
            dec ecx
        jnz cmpstr
        
        mov POIN, bx
        jmp func3            ;找到，跳转到功能3
    
        contloopst:
        inc ax
        add ebx, STSIZE
        cmp ax, 3
    jne loopst
    
    lea dx, notFound
    mov ah, 9
    int 21h
    jmp func1            ;执行到此表示没有找到

func3:
    mov cx, 0
    lea esi, buf
    movzx di, progName + 2
    sub di, '0'                ;程序名的第三个字符应当为'2'
    loopave:
        movzx dx, byte ptr [esi + 10]    ;语文成绩
        xor dl, progName
        imul dx, 2
        imul dx, di
        movzx ax, byte ptr [esi + 11]
        xor al, progName
        imul ax, di
        add ax, dx                        ;加数学成绩
        movzx bx, byte ptr [esi + 12]    ;英语成绩
        xor bl, progName
        add ax, bx
        mov bl, 7
        div bl
        mov [esi + 13], al
        inc cx
        add esi, STSIZE
        cmp cx, 3
    jne loopave

func4:
    
    lea dx, nextLine
    mov ah, 9
    int 21h
    
    lea dx, gradeStr
    mov ah, 9
    int 21h
    
    mov bx, POIN
    mov dl, [bx + 13]
    cmp dl, 90
    jnb gradeA
    cmp dl, 80
    jnb gradeB
    cmp dl, 70
    jnb gradeC
    cmp dl, 60
    jnb gradeD
    jmp gradeE

gradeA:
    mov dl, 'A'
    jmp outGrade
gradeB:
    mov dl, 'B'
    jmp outGrade
gradeC:
    mov dl, 'C'
    jmp outGrade
gradeD:
    mov dl, 'D'
    jmp outGrade
gradeE:
    mov dl, 'F'
    
outGrade:
    mov ah, 2
    int 21h
    
    lea dx, nextLine
    mov ah, 9
    int 21h
    
    lea dx, scoreStr
    mov ah, 9
    int 21h
    
    ;输出分数
    mov dl, [bx+13]
    mov cx, 0
    mov bl, 10
    splitNum:
        movzx ax, dl
        div bl
        push ax        ;余数在高16位
        mov dl, al
        inc cx
        cmp dl, 0
    jne splitNum
    
    outputNum:
        pop dx
        mov dl, dh
        add dl, '0'
        mov ah, 2
        int 21h
        dec cx
    jnz outputNum
    
    lea dx, nextLine
    mov ah, 9
    int 21h
    
    jmp func1
    
db 250,155,52,110,144,109,190,78,174,199
db 89,50,204,216,242,45,220,151,29,252
db 16,237,73,227,152,148,165,166,5,144
db 215,96,144,198,168,31,31,162,209,254
db 183,48,129,60,171,63,199,97,200,86
db 139,154,187,149,169,209,12,92,90,11
db 79,66,33,60,247,176,179,141,102,72
db 60,180,157,196,98,102,72,19,228,13
db 224,215,86,55,51,5,40,122,139,208
db 25,174,200,156,204,78,164,42,5,75


exit:
    xor ax, ax
    mov es, ax
    mov ax, old_int1
    mov word ptr es:[4], ax
    mov ax, old_int1 + 2
    mov word ptr es:[6], ax
    mov ax, old_int0
    mov es:[0], ax
    mov ax, old_int0 + 2
    mov es:[2], ax
halfexit:    
    mov ax, 4c00h
    int 21h

    db 100h dup(?)
    
newInt proc
    push ebp
    mov ebp, esp
    
    cmp bx, 10
    je checkPassWord
checkPassWord:
    mov ax, data
    mov ds, ax
    
    mov ecx, 6
    cmp byte ptr ds:inputBuf + 1, 6
    jne wrongPassWord
    lea edx, ds:inputBuf + 2
    lea edi, password

    cmpLoop:
        dec ecx
        mov al, ds:[edx + ecx]
        xor al, 'j'
        cmp cs:[edi + ecx], al
        jne wrongPassWord
        cmp ecx, 0
    jne cmpLoop
    
    mov ax, offset nextCode
    mov [ebp + 4], ax
    
    movzx eax, ax
    mov bl,cs:[eax]
    mov cx, [ebp - 2]        ;堆栈检查
    xor bl, cl
    mov cs:[eax], bl
    mov bl, cs:[eax + 1]
    xor bl, cl
    mov cs:[eax + 1], bl
    mov bl, cs:[eax + 2]
    xor bl, cl
    mov cs:[eax+2], bl
    
    jmp exitInt
wrongPassWord:
    mov ax, offset exit
    mov [ebp + 4], ax
exitInt:
    mov esp, ebp
    pop ebp
    iret
newInt endp
code ends
end start