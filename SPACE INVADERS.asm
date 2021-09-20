;Ovreiu Auraș, grupa 9, semigrupa 2

.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

;în proiect este posibilă deplasarea navei de la stânga la dreapta și invers după 10 evenimente de timp(2 secunde)-nava se mișcă singură și există posibilitatea de
;a trage apăsând pe SHOOT. Extratereștrii se mișcă de la stânga la dreapta și invers în primele 70 de evenimente de timp la fiecare 300 de evenimente, iar atunci se
;deplasează în jos prin suprascrierea lanțului și ștergerea primelor rânduri de extratereștrii de sus(la fiecare 300 de evenimente se șterge câte un rând). Fantomele
;pot să tragă gloanțe la anumite evenimente de timp, iar atât gloanțele lor cât și ale navei distrug o parte din scuturi. Fieare extraterestru are un anumit scor,
;astfel că atunci când glonțul navei lovește o fantomă de pe cel mai apropiat rând scorul va fi între 0 și 100, de pe al doilea între 100 și 200, iar cel mai
;depărtat rând între 400 și 500(scorul maxim care poate fi atins astfel este 490). Fantomele dintre poziția de start a navei și colțul din stânga au scoruri de la
;10 la 50(cea mai din stânga are 50), iar cele dintre poziția de start și colțul din dreapta de la 60 la 90(cea mai din dreapta are 90). Dacă vom trage când nava 
;se mișcă de la poziția inițială la colțul stânga scorul va crește, din colțul stânga la poziția inițială scade, de la poziția inițială la colțul dreapta crește,
;din colțul dreapta la poziția inițială scade. După ce glonțul extraterestrului lovește nava aceasta va avea cu o viață mai puțin, iar dacă rămâne fără nicio viață
;jocul se oprește și se va afișa prin mijlocul ferestrei GAME OVER(se vor deplasa doar fantomele din acel moment). Dacă se apasă pe SHOOT la cel mult 10 evenimente  
;după ce glonțul lovește nava aceasta din urmă va avea din nou 3 vieți(ai pierdut dacă glonțul te lovește de 3 ori la rând fără să apeși pe SHOOT)
;jocul durează cel mult 1500 de evenimente(în jur de 5 minute), moment în care dispar toți extratereștrii și se afișează GAME OVER în mijlocul ferestrei

;singura problemă este că după mai multe click-uri succesive pe SHOOT mai apare o navă în fereastră sau uneori chiar două pe anumite poziții, iar unele gloanțe nu se șterg
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Space Invaders-Proiect",0
area_width EQU 640
area_height EQU 480

area DD 0
;constante ce delimitează zona propriu-zisă de joc
button_x equ 145
button_y equ 100
button_size equ 350
;dimensiunile simbolurilor desenate
ship_height dd 15
ship_width dd 20
scut_width dd 40
scut_height dd 45
extra_width dd 15
extra_height dd 15

ship_symbol dd 0
scut_symbol dd 0
extra_symbol dd 0

counter DD 0 ; numara evenimentele de tip timer
;countere pentru a ști la ce moment am apăsat pe SHOOT(când tragem se resetează)
;acestea asigură posibilitatea de a trage la orice moment de timp
counterok dd 0
counterok1 dd 0
counterok2 dd 0
counterok3 dd 0
counterok4 dd 0
counterok5 dd 0
counterok6 dd 0
counterok7 dd 0
counterok8 dd 0
counterok9 dd 0
counterok10 dd 0
counterok11 dd 0
counterok12 dd 0
counterok13 dd 0
counterok14 dd 0
counterok15 dd 0

;countere pentru detectarea coliziunilor dintre gloanțe și navă
counter_ship0 dd 0
counter_ship1 dd 0
counter_ship2 dd 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24;culoare simbol
arg6 EQU 28;culoare fundal simbol

symbol_width EQU 10
symbol_height EQU 20

culor dd 0

include digits.inc
include letters.inc
include ship.inc
include scut.inc
include extra.inc

.code

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text_yellow
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text_yellow
make_space:	
	mov eax, 26 ; de la 0 pana la 26 sunt litere, 27 e space
	lea esi, letters
draw_text_yellow:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov ebx, [ebp+arg5];culoare scris
	mov dword ptr [edi], ebx
	jmp simbol_pixel_next
simbol_pixel_alb:
    mov edx, [ebp+arg6];culoare fundal simbol
	mov dword ptr [edi], edx
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y, color_scris, color_fundal
    push color_fundal
    push color_scris
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 24
endm

;funcție pentru desenarea navei
make_ship proc
   push ebp
   mov ebp, esp
   pusha
   mov eax, [ebp+arg1]
   mov ship_symbol, eax
   lea esi, ship
   
deseneaza_ship:   
   mov ebx, ship_width
	mul ebx
	mov ebx, ship_height
	mul ebx
	add esi, eax
	mov ecx, ship_height
	
bucla_simbol_linii_ship:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, ship_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, ship_width
bucla_simbol_coloane_ship:
	cmp byte ptr [esi], 0
	je simbol_pixel_next_ship
	mov edx, [ebp+arg5];penrtu culoarea navei
	mov dword ptr [edi], edx

simbol_pixel_next_ship:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_ship
	pop ecx
	loop bucla_simbol_linii_ship
	popa
	mov esp, ebp
	pop ebp
	ret
make_ship endp
 
make_ship_macro macro symbol, drawArea, x1, y1, color_ship
    push color_ship
    push y1
	push x1
	push drawArea
	push symbol
	call make_ship
	add esp, 20
endm 

;funcție pentru desenarea scutului
make_scut proc
   push ebp
   mov ebp, esp
   pusha
   mov eax, [ebp+arg1]
   mov scut_symbol, eax
   lea esi, scut
   mov culor, 0C71585h
   
deseneaza_scut:   
   mov ebx, scut_width
	mul ebx
	mov ebx, scut_height
	mul ebx
	add esi, eax
	mov ecx, scut_height
	
bucla_simbol_linii_scut:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, scut_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, scut_width
bucla_simbol_coloane_scut:
	cmp byte ptr [esi], 0
	je simbol_pixel_next_scut
	mov edx, culor
	mov dword ptr [edi], edx
	
simbol_pixel_next_scut:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_scut
	pop ecx
	loop bucla_simbol_linii_scut
	popa
	mov esp, ebp
	pop ebp
	ret
make_scut endp

make_scut_macro macro symbol, drawArea, x2, y2
    push y2
	push x2
	push drawArea
	push symbol
	call make_scut
	add esp, 16
endm 

;funcție pentru desenarea extraterestrului
make_extra proc
   push ebp
   mov ebp, esp
   pusha
   mov eax, [ebp+arg1]
   mov extra_symbol, eax
   lea esi, extra
   mov culor, 00FF00h
   
deseneaza_extra:   
   mov ebx, extra_width
	mul ebx
	mov ebx, extra_height
	mul ebx
	add esi, eax
	mov ecx, extra_height
	
bucla_simbol_linii_extra:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, extra_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, extra_width
bucla_simbol_coloane_extra:
	cmp byte ptr [esi], 0
	je simbol_pixel_next_extra
	mov edx, culor
	mov dword ptr [edi], edx
	
simbol_pixel_next_extra:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_extra
	pop ecx
	loop bucla_simbol_linii_extra
	popa
	mov esp, ebp
	pop ebp
	ret
make_extra endp

make_extra_macro macro symbol, drawArea, x2, y2
    push y2
	push x2
	push drawArea
	push symbol
	call make_extra
	add esp, 16
endm 

;macro pentru afișarea tuturor extratereștrilor
macro_extra_lant macro extra_symbol, area, x, y, len
	local loop_extra, out_extra, vert_extra
	mov ebx, y
	
vert_extra:
	mov ecx, x;inserarea începe de la o poziție dată
	add ebx, 30
loop_extra:
	sub ecx, 30
	cmp ecx, x-len;inserarea se termină la o poziție dată
	jle vert_extra;dacă am afișat toți extratereștrii de care aveam nevoie pe rândul respectiv trecem pe rândul următor 
	cmp ebx, button_size+y-180;dacă am inserat toți extratereștrii de care aveam nevoie ieșim din buclă
	jge out_extra
	push ecx
	push ebx
	make_extra_macro extra_symbol, area, ecx, ebx
	pop ebx
	pop ecx
	cmp ecx, 0
	jne loop_extra;afișăm pe un rând câți extratereștrii avem nevoie
out_extra:
	endm

;macro pentru ștergerea primelor rânduri de extratereștrii de sus(vom folosi pentru deplasarea în jos a acestora)	
down_extra macro symbol, area, x, y
    local oriz_line, out5
	mov ecx, x
oriz_line:
	cmp ecx, button_x
    jle out5
	sub ecx, 9
	push ecx
	make_text_macro symbol, area, ecx, y, 008000h, 0
	pop ecx
	loop oriz_line
	out5:
endm
	
;macro pentru desenarea unei linii orizontale	
line_horizontal macro x, y, len, color
   local bucla

   mov eax, y
   mov ebx, area_width
   mul ebx
   add eax, x
   shl eax, 2
   add eax, area
   mov ecx, len
   bucla:
   mov dword ptr[eax], color
   add eax, 4
   loop bucla
   endm	
 
;macro pentru desenarea unei linii verticale 
line_vertical macro x, y, len, color
   local bucla

   mov eax, y
   mov ebx, area_width
   mul ebx
   
   add eax, x
   shl eax, 2
   add eax, area
   mov ecx, len
   bucla:
   mov dword ptr[eax], color
   add eax, 4*area_width
   loop bucla
   endm 

;macro pentru desenarea unui anumit număr de linii succesiv de o anumită lungime și culoare
draw_lines macro x, y, nr_lines, len, color;vom folosi macro-ul pentru desenarea gloanțelor și afișarea de linii succesive în afara zonei de joc și pe marginile acesteia
    local out_afis, afis
    mov ecx, y
afis:
    cmp ecx, y-nr_lines
	je out_afis
	push ecx
	line_horizontal x, ecx, len, color
	pop ecx
	loop afis
out_afis:
   endm

;macro pentru deplasarea la stânga a navei
move_ship_left_macro macro ship_symbol, area, x, y
    make_text_macro ' ', area, x, y, 008000h, 0
		make_text_macro ' ', area, x+10, y, 008000h, 0;ștergem nava
		make_ship_macro ship_symbol, area, x-20, y, 00ffffh;o desenăm cu o poziție mai la stânga
endm

;macro pentru deplasarea la dreapta a navei
move_ship_right_macro macro ship_symbol, area, x, y
    make_text_macro ' ', area, x, y, 008000h, 0
		make_text_macro ' ', area, x+10, y, 008000h, 0;ștergem nava
		make_ship_macro ship_symbol, area, x+20, y, 00ffffh;o desenăm cu o poziție mai la dreapta
endm

;macro pentru deplasarea glonțului navei
make_bullet macro symbol, area, x, y
    make_text_macro symbol, area, x-5, y+13, 008000h, 0;ștergem glonțul
	   draw_lines x, y, 3, 3, 808080h;desenăm glonțul la altă poziție
endm

;macro pentru deplasarea glonțului extraterestrului
make_bullet_extra macro symbol, area, x, y
    make_text_macro symbol, area, x-5, y-32, 008000h, 0
	   draw_lines x, y, 3, 3, 0FF8C00h
endm
  
;macro pentru deplasarea la stânga a lanțului de extratereștrii  
move_extra_left macro extra_symbol, area, x, y
    macro_extra_lant extra_symbol, area, x, y+10, 300;apelăm macroul ce desenează lanțul
    
    make_text_macro ' ', area, x-5, button_y+40, 008000h, 0;ștergem cea mai din dreapta coloană ocupată de extratereștrii prin apelări succesive ale macroului make_text_macro
    make_text_macro ' ', area, x+5, button_y+40, 008000h, 0

    make_text_macro ' ', area, x-5, button_y+70, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+70, 008000h, 0

    make_text_macro ' ', area, x-5, button_y+100, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+100, 008000h, 0
	
    make_text_macro ' ', area, x-5, button_y+130, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+130, 008000h, 0
	
	make_text_macro ' ', area, x-5, button_y+160, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+160, 008000h, 0
endm

;macro pentru deplasarea la dreapta a lanțului de extratereștrii  
move_extra_right macro extra_symbol, area, x, y
    macro_extra_lant extra_symbol, area, x+300, y+10, 300
    
    make_text_macro ' ', area, x-5, button_y+40, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+40, 008000h, 0
 
    make_text_macro ' ', area, x-5, button_y+70, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+70, 008000h, 0

    make_text_macro ' ', area, x-5, button_y+100, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+100, 008000h, 0
	
    make_text_macro ' ', area, x-5, button_y+130, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+130, 008000h, 0
	
	make_text_macro ' ', area, x-5, button_y+160, 008000h, 0
    make_text_macro ' ', area, x+5, button_y+160, 008000h, 0
endm	

;macro pentru ștergerea unei porțiuni din scut(atunci când acesta este lovit de glonț)
destroy_scut macro symbol, area, x, y
        make_text_macro symbol, area, x, y, 008000h, 0;afișăm spații libere peste porțiunea ce va fi străpunsă de glonț
		make_text_macro symbol, area, x, y+20, 008000h, 0
		make_text_macro symbol, area, x, y+40, 008000h, 0
	endm

;macro pentru ștergerea unui extraterestru și a glonțului care îl lovește	
destroy_extra macro symbol, area, x, y	
    make_bullet symbol, area, x+10, y+20
		make_text_macro symbol, area, x, y, 008000h, 0
		make_text_macro symbol, area, x+10, y, 008000h, 0
		make_text_macro symbol, area, x, y+2, 008000h, 0
		make_text_macro symbol, area, x+10, y+2, 008000h, 0
	endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y 
draw proc

	push ebp
	mov ebp, esp
	pusha
	
	;desenăm linii gri în afara zonei de joc
    draw_lines 0, 480, 30, 640, 808080h
    draw_lines 0, 90, 90, 640, 808080h
    draw_lines 0, 450, 360, 145, 808080h
    draw_lines 495, 450, 360, 145, 808080h
    
	;delimităm zona de joc prin desenarea unor linii de diferite culori în jurul acesteia
	line_horizontal button_x, button_y+button_size, button_size, 0ff0000h
	line_horizontal button_x, button_y-10, button_size, 0ff0000h
    line_vertical button_x, button_y-10, button_size+10, 0ff0000h
	line_vertical button_x+button_size, button_y-10, button_size+10, 0ff0000h
	
	line_horizontal button_x, button_y+button_size+1, button_size, 0ffff00h
	line_horizontal button_x, button_y-11, button_size, 0ffff00h
    line_vertical button_x-1, button_y-10, button_size+10, 0ffff00h
	line_vertical button_x+button_size+1, button_y-10, button_size+10, 0ffff00h
	
	line_horizontal button_x, button_y+button_size+2, button_size, 00ff00h
	line_horizontal button_x, button_y-12, button_size, 00ff00h
    line_vertical button_x-2, button_y-12, button_size+10, 00ff00h
	line_vertical button_x+button_size+2, button_y-10, button_size+10, 00ff00h
	
	;desenăm titlul proiectului
	make_text_macro 'S', area, 250, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'P', area, 260, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'A', area, 270, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'C', area, 280, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'E', area, 290, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro ' ', area, 300, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'I', area, 310, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'N', area, 320, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'V', area, 330, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'A', area, 340, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'D', area, 350, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'E', area, 360, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'R', area, 370, 40, 0FF00FFh, 0FFFAFAh
	make_text_macro 'S', area, 380, 40, 0FF00FFh, 0FFFAFAh
	
	;desenăm butonul pentru tragere
	make_text_macro 'S', area, 295, 455, 0ff0000h, 0FFFF00h
	make_text_macro 'H', area, 305, 455, 0ff0000h, 0FFFF00h
	make_text_macro 'O', area, 315, 455, 0ff0000h, 0FFFF00h
	make_text_macro 'O', area, 325, 455, 0ff0000h, 0FFFF00h
	make_text_macro 'T', area, 335, 455, 0ff0000h, 0FFFF00h
	
work:
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
   mov eax, [ebp+arg2]
   cmp eax, 295
   jl afisare_litere
   cmp eax, 345
   jg afisare_litere
   mov eax, [ebp+arg3]
   cmp eax, 455
   jl afisare_litere
   cmp eax, 475
   jg afisare_litere
   
   cmp counter, 1500
   jg afisare_litere;după 1500 de evenimente dispar toți extratereștrii și jocul se termină
   cmp counter_ship0, 310;dacă acest counter ajunge la 310 atunci înseamnă că nu s-a dat click pe buton pentru a opri glonțul să lovească nava și jocul se termină
   jg afisare_litere
   cmp counter_ship1, 310;dacă acest counter ajunge la 310 atunci înseamnă că nu s-a dat click pe buton pentru a opri glonțul să lovească nava și jocul se termină
   jg afisare_litere
   cmp counter_ship2, 310;dacă acest counter ajunge la 310 atunci înseamnă că nu s-a dat click pe buton pentru a opri glonțul să lovească nava și jocul se termină
   jg afisare_litere
   
   mov eax, counter
   mov ebx, 300
   div ebx
   
   ;ținem evidența pozițiilor la care se afla nava când am dat click pe buton(inclusiv dacă nava se mișcă spre stânga sau spre dreapta)
   cmp edx, 10
   jl click
   cmp edx, 20
   jl click1
   cmp edx, 30
   jl click2
   cmp edx, 40
   jl click3
   cmp edx, 50
   jl click4
   cmp edx, 60
   jl click5
   cmp edx, 70
   jl click6
   cmp edx, 80
   jl respawn1;click7
   cmp edx, 90
   jl click8
   cmp edx, 100
   jl click7
   cmp edx, 110
   jl click6
   cmp edx, 120
   jl click5
   cmp edx, 130
   jl click4
   cmp edx, 140
   jl click3
   cmp edx, 150
   jl respawn2;click2
   cmp edx, 160
   jl click1
   cmp edx, 170
   jl click
   cmp edx, 180
   jl click9
   cmp edx, 190
   jl click10
   cmp edx, 200
   jl click11
   cmp edx, 210
   jl click12
   cmp edx, 220
   jl click13
   cmp edx, 230
   jl click14
   cmp edx, 240
    jl click15
   cmp edx, 250
   jl click14
   cmp edx, 260
   jl click13
   cmp edx, 270
   jl click12
   cmp edx, 280
   jl respawn3;click11
   cmp edx, 290
   jl click10
   cmp edx, 300
   jl click9

;dacă am ajuns aici înseamnă că am dat click pentru a salva nava de glonț și resetăm counterele pentru coliziunile dintre gloanțe și navă   
respawn1:
    make_ship_macro ship_symbol, area, 400, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 425, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 450, 105, 0ff0000h
	mov counter_ship1, 0
	mov counter_ship0, 0
	mov counter_ship2, 0
	jmp click7
respawn2:
    make_ship_macro ship_symbol, area, 400, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 425, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 450, 105, 0ff0000h
	mov counter_ship2, 0
	mov counter_ship1, 0
	mov counter_ship0, 0
	jmp click2
respawn3:
    make_ship_macro ship_symbol, area, 400, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 425, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 450, 105, 0ff0000h
	 mov counter_ship0, 0
   mov counter_ship1, 0
   mov counter_ship2, 0
	jmp click11	

;în momentul în care am dat click desenăm glonțul în fața navei, iar counterul pentru glonțul respectiv se resetează   
click:
  draw_lines 330, 430, 3, 3, 808080h
  mov counterok, 0
   jmp evt_timer
click1:
   draw_lines 310, 430, 3, 3, 808080h
   mov counterok1, 0
   jmp evt_timer
click2:
  draw_lines 290, 430, 3, 3, 808080h
  mov counterok2, 0
   jmp evt_timer
click3:
   draw_lines 270, 430, 3, 3, 808080h
   mov counterok3, 0
   jmp evt_timer 
click4:
  draw_lines 250, 430, 3, 3, 808080h
  mov counterok4, 0
   jmp evt_timer
click5:
   draw_lines 230, 430, 3, 3, 808080h
   mov counterok5, 0
   jmp evt_timer
click6:
  draw_lines 210, 430, 3, 3, 808080h
  mov counterok6, 0
   jmp evt_timer
click7:
   draw_lines 190, 430, 3, 3, 808080h
   mov counterok7, 0
   jmp evt_timer
click8:
  draw_lines 170, 430, 3, 3, 808080h
  mov counterok8, 0
   jmp evt_timer
click9:
   draw_lines 350, 430, 3, 3, 808080h
   mov counterok9, 0
   jmp evt_timer
click10:
  draw_lines 370, 430, 3, 3, 808080h
  mov counterok10, 0
   jmp evt_timer
click11:
   draw_lines 390, 430, 3, 3, 808080h
   mov counterok11, 0
   jmp evt_timer 
click12:
  draw_lines 410, 430, 3, 3, 808080h
  mov counterok12, 0
   jmp evt_timer
click13:
   draw_lines 430, 430, 3, 3, 808080h
   mov counterok13, 0
   jmp evt_timer
click14:
  draw_lines 450, 430, 3, 3, 808080h
  mov counterok14, 0
   jmp evt_timer
click15:
  draw_lines 470, 430, 3, 3, 808080h
  mov counterok15, 0
   jmp evt_timer

;desenăm scorul, viețile navei, scuturile și lanțul de extratereștrii când începe jocul
start_1:
    make_text_macro 'S', area, 165, 100, 0DEB887h, 0
	make_text_macro 'C', area, 175, 100, 0DEB887h, 0
	make_text_macro 'O', area, 185, 100, 0DEB887h, 0
	make_text_macro 'R', area, 195, 100, 0DEB887h, 0
	make_text_macro 'E', area, 205, 100, 0DEB887h, 0
	
	make_text_macro '0', area, 225, 100, 0DEB887h, 0
	make_text_macro '0', area, 235, 100, 0DEB887h, 0
	make_text_macro '0', area, 245, 100, 0DEB887h, 0
	make_text_macro '0', area, 255, 100, 0DEB887h, 0
	make_text_macro '0', area, 265, 100, 0DEB887h, 0
	
    make_ship_macro ship_symbol, area, 400, 105, 0ff0000h
    make_ship_macro ship_symbol, area, 425, 105, 0ff0000h
	make_ship_macro ship_symbol, area, 450, 105, 0ff0000h
	
    make_scut_macro scut_symbol, area, 165, 350
	make_scut_macro scut_symbol, area, 255, 350
	make_scut_macro scut_symbol, area, 345, 350
	make_scut_macro scut_symbol, area, 435, 350
	macro_extra_lant extra_symbol, area, button_x+button_size-30, button_y+10, 300
	jmp evt_timer

;ștergem nava și o afișăm la poziția inițială atunci când aceasta ar trebui să ajungă în poziția inițială
start_game: 
    make_text_macro ' ', area, 340, 430, 008000h, 0
	make_text_macro ' ', area, 350, 430, 008000h, 0
    make_ship_macro ship_symbol, area, 320, 430, 00ffffh
	draw_lines 351, 277, 3, 3, 0FF8C00h;desenăm unul dintre gloanțele trase de extratereștrii când nava ajunge în poziția inițială
	mov counter_ship0, 30;setăm counterul pentru coliziunea glonț-navă la valoarea respectivă
	jmp evt_timer

;etichete pentru deplasarea gloanțelor trase de navă
move_bullet:
	   make_bullet ' ', area, 330, 400
    	jmp evt_timer
move_bullet1:
	    make_bullet ' ', area, 330, 370
       jmp evt_timer
move_bullet2:
	    make_bullet ' ', area, 330, 340
    	jmp evt_timer
move_bullet3:
	    make_bullet ' ', area, 330, 310
    	jmp evt_timer
move_bullet4:
	   make_bullet ' ', area, 330, 280
    	jmp evt_timer
move_bullet5:;când glonțul lovește extraterestrul îl ștergem și modificăm scorul
        destroy_extra ' ', area, 315, 260 
		
	    make_text_macro '1', area, 255, 100, 0DEB887h, 0
		cmp counter, 300;după aceste intervale de timp scorul va fi mai mare la lovirea extraterestrului(atunci când îi lovim pe cei situați pe o linie mai depărtată de navă)
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer

move_bullet_1:
	    make_bullet ' ', area, 310, 400
    	jmp evt_timer
move_bullet1_1:
	    make_bullet ' ', area, 310, 370
        jmp evt_timer
move_bullet2_1:
	    make_bullet ' ', area, 310, 340
    	jmp evt_timer
move_bullet3_1:
	    make_bullet ' ', area, 310, 310
    	jmp evt_timer
move_bullet4_1:
	    make_bullet ' ', area, 310, 280
    	jmp evt_timer
move_bullet5_1:
	    make_bullet ' ', area, 310, 250
    	jmp evt_timer
move_bullet6_1:
	    make_bullet ' ', area, 310, 220
    	jmp evt_timer
move_bullet7_1:
	    make_bullet ' ', area, 310, 190
        jmp evt_timer
move_bullet8_1:
	    make_bullet ' ', area, 310, 160
    	jmp evt_timer
move_bullet9_1:
	    make_bullet ' ', area, 310, 130
    	jmp evt_timer
move_bullet10_1:
	    make_text_macro ' ', area, 305, 125, 008000h, 0;dacă glonțul nu lovește nimic atunci îl ștergem când ajunge la partea superioară a zonei de joc
    	jmp evt_timer
		
move_bullet_2:
	   make_bullet ' ', area, 290, 400
    	jmp evt_timer
delete1:
        destroy_scut ' ', area, 290, 350
move_bullet1_2:
	    make_bullet ' ', area, 290, 370
    	jmp evt_timer
move_bullet2_2:
	    make_bullet ' ', area, 290, 340
    	jmp evt_timer
move_bullet3_2:
	    make_bullet ' ', area, 290, 310
    	jmp evt_timer
move_bullet4_2:
	    make_bullet ' ', area, 290, 280
    	jmp evt_timer
move_bullet5_2:
        destroy_extra ' ', area, 280, 260
		
		make_text_macro '2', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
	
move_bullet_3:
	   make_bullet ' ', area, 270, 400
    	jmp evt_timer
delete2:
    destroy_scut ' ', area, 270, 350
move_bullet1_3:
	    make_bullet ' ', area, 270, 370
    	jmp evt_timer
move_bullet2_3:
	    make_bullet ' ', area, 270, 340
    	jmp evt_timer
move_bullet3_3:
	    make_bullet ' ', area, 270, 310
    	jmp evt_timer
move_bullet4_3:
	    make_bullet ' ', area, 270, 280
		jmp evt_timer
move_bullet5_3:
      destroy_extra ' ', area, 255, 260
	  make_text_macro ' ', area, 260, 270, 008000h, 0
	  
	  make_text_macro '3', area, 255, 100, 0DEB887h, 0
	  cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
	  jmp evt_timer
    	 		
move_bullet_4:
	   make_bullet ' ', area, 250, 400
    	jmp evt_timer
move_bullet1_4:
	    make_bullet ' ', area, 250, 370
    	jmp evt_timer
move_bullet2_4:
	    make_bullet ' ', area, 250, 340
    	jmp evt_timer
move_bullet3_4:
	    make_bullet ' ', area, 250, 310
    	jmp evt_timer
move_bullet4_4:
	    make_bullet ' ', area, 250, 280
    	jmp evt_timer
move_bullet5_4:
	    make_bullet ' ', area, 250, 250
    	jmp evt_timer
move_bullet6_4:
	    make_bullet ' ', area, 250, 220
    	jmp evt_timer
move_bullet7_4:
	    make_bullet ' ', area, 250, 190
    	jmp evt_timer
move_bullet8_4:
	    make_bullet ' ', area, 250, 160
    	jmp evt_timer
move_bullet9_4:
	    make_bullet ' ', area, 250, 130
    	jmp evt_timer
move_bullet10_4:
    make_text_macro ' ', area, 245, 125, 008000h, 0
	jmp evt_timer

move_bullet_5:
	   make_bullet ' ', area, 230, 400
    	jmp evt_timer
move_bullet1_5:
	    make_bullet ' ', area, 230, 370
    	jmp evt_timer
move_bullet2_5:
	    make_bullet ' ', area, 230, 340
    	jmp evt_timer
move_bullet3_5:
	    make_bullet ' ', area, 230, 310
    	jmp evt_timer
move_bullet4_5:
	    make_bullet ' ', area, 230, 280
    	jmp evt_timer
move_bullet5_5:
	    destroy_extra ' ', area, 220, 260
		
		make_text_macro '4', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
		
move_bullet_6:
	   make_bullet ' ', area, 210, 400
    	jmp evt_timer
move_bullet1_6:
	    make_bullet ' ', area, 210, 370
    	jmp evt_timer
move_bullet2_6:
	    make_bullet ' ', area, 210, 340
    	jmp evt_timer
move_bullet3_6:
	    make_bullet ' ', area, 210, 310
    	jmp evt_timer
move_bullet4_6:
	    make_bullet ' ', area, 210, 280
    	jmp evt_timer
move_bullet5_6:
	    destroy_extra ' ', area, 195, 260
		
		make_text_macro '5', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
		
move_bullet_7:
	   make_bullet ' ', area, 190, 400
    	jmp evt_timer
delete3:
    destroy_scut ' ', area, 190, 350
move_bullet1_7:
	    make_bullet ' ', area, 190, 370
    	jmp evt_timer
move_bullet2_7:
	    make_bullet ' ', area, 190, 340
    	jmp evt_timer
move_bullet3_7:
	    make_bullet ' ', area, 190, 310
    	jmp evt_timer
move_bullet4_7:
	    make_bullet ' ', area, 190, 280
    	jmp evt_timer
move_bullet5_7:
	    make_bullet ' ', area, 190, 250
    	jmp evt_timer
move_bullet6_7:
	    make_bullet ' ', area, 190, 220
    	jmp evt_timer
move_bullet7_7:
	    make_bullet ' ', area, 190, 190
    	jmp evt_timer
move_bullet8_7:
	    make_bullet ' ', area, 190, 160
    	jmp evt_timer
move_bullet9_7:
	    make_bullet ' ', area, 190, 130
    	jmp evt_timer
move_bullet10_7:
	    make_text_macro ' ', area, 185, 125, 008000h, 0
    	jmp evt_timer	
		
move_bullet_8:
	   make_bullet ' ', area, 170, 400
    	jmp evt_timer
delete4:
     destroy_scut ' ', area, 170, 350
move_bullet1_8:
	    make_bullet ' ', area, 170, 370
    	jmp evt_timer
move_bullet2_8:
	    make_bullet ' ', area, 170, 340
    	jmp evt_timer
move_bullet3_8:
	    make_bullet ' ', area, 170, 310
    	jmp evt_timer
move_bullet4_8:
	    make_bullet ' ', area, 170, 280
    	jmp evt_timer
move_bullet5_8:
	    make_bullet ' ', area, 170, 250
    	jmp evt_timer
move_bullet6_8:
	    make_bullet ' ', area, 170, 220
    	jmp evt_timer
move_bullet7_8:
	    make_bullet ' ', area, 170, 190
    	jmp evt_timer
move_bullet8_8:
	    make_bullet ' ', area, 170, 160
    	jmp evt_timer
move_bullet9_8:
	    make_bullet ' ', area, 170, 130
    	jmp evt_timer
move_bullet10_8:
    make_text_macro ' ', area, 165, 125, 008000h, 0
	jmp evt_timer
		
move_bullet_9:
	   make_bullet ' ', area, 350, 400
    	jmp evt_timer
delete5:
		destroy_scut ' ', area, 350, 350
move_bullet1_9:
	    make_bullet ' ', area, 350, 370
    	jmp evt_timer
move_bullet2_9:
	    make_bullet ' ', area, 350, 340
    	jmp evt_timer
move_bullet3_9:
	    make_bullet ' ', area, 350, 310
    	jmp evt_timer
move_bullet4_9:
	    make_bullet ' ', area, 350, 280
    	jmp evt_timer
move_bullet5_9:
	    destroy_extra ' ', area, 340, 260
		
		make_text_macro '6', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
	
move_bullet_10:
	   make_bullet ' ', area, 370, 400
    	jmp evt_timer
delete6:
		destroy_scut ' ', area, 370, 350
move_bullet1_10:
	    make_bullet ' ', area, 370, 370
    	jmp evt_timer
move_bullet2_10:
	    make_bullet ' ', area, 370, 340
    	jmp evt_timer
move_bullet3_10:
	    make_bullet ' ', area, 370, 310
    	jmp evt_timer
move_bullet4_10:
	    make_bullet ' ', area, 370, 280
    	jmp evt_timer
move_bullet5_10:
	    make_bullet ' ', area, 370, 250
    	jmp evt_timer
move_bullet6_10:
	    make_bullet ' ', area, 370, 220
    	jmp evt_timer
move_bullet7_10:
	    make_bullet ' ', area, 370, 190
    	jmp evt_timer
move_bullet8_10:
	    make_bullet ' ', area, 370, 160
    	jmp evt_timer
move_bullet9_10:
	    make_bullet ' ', area, 370, 130
    	jmp evt_timer
move_bullet10_10:
	    make_text_macro ' ', area, 365, 125, 008000h, 0
    	jmp evt_timer
		
move_bullet_11:
	   make_bullet ' ', area, 390, 400
    	jmp evt_timer
move_bullet1_11:
	    make_bullet ' ', area, 390, 370
    	jmp evt_timer
move_bullet2_11:
	    make_bullet ' ', area, 390, 340
    	jmp evt_timer
move_bullet3_11:
	    make_bullet ' ', area, 390, 310
    	jmp evt_timer
move_bullet4_11:
	    make_bullet ' ', area, 390, 280
    	jmp evt_timer
move_bullet5_11:
	    destroy_extra ' ', area, 375, 260
		
		make_text_macro '7', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
		
move_bullet_12:
	   make_bullet ' ', area, 410, 400
    	jmp evt_timer
move_bullet1_12:
	    make_bullet ' ', area, 410, 370
    	jmp evt_timer
move_bullet2_12:
	    make_bullet ' ', area, 410, 340
    	jmp evt_timer
move_bullet3_12:
	    make_bullet ' ', area, 410, 310
    	jmp evt_timer
move_bullet4_12:
	    make_bullet ' ', area, 410, 280
    	jmp evt_timer
move_bullet5_12:
	    destroy_extra ' ', area, 400, 260
		
		make_text_macro '8', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
		
move_bullet_13:
	   make_bullet ' ', area, 430, 400
    	jmp evt_timer
move_bullet1_13:
	    make_bullet ' ', area, 430, 370
    	jmp evt_timer
move_bullet2_13:
	    make_bullet ' ', area, 430, 340
    	jmp evt_timer
move_bullet3_13:
	    make_bullet ' ', area, 430, 310
    	jmp evt_timer
move_bullet4_13:
	   make_bullet ' ', area, 430, 280
    	jmp evt_timer
move_bullet5_13:
	    make_bullet ' ', area, 430, 250
    	jmp evt_timer
move_bullet6_13:
	    make_bullet ' ', area, 430, 220
    	jmp evt_timer
move_bullet7_13:
	    make_bullet ' ', area, 430, 190
    	jmp evt_timer
move_bullet8_13:
	   make_bullet ' ', area, 430, 160
    	jmp evt_timer
move_bullet9_13:
	    make_bullet ' ', area, 430, 130
    	jmp evt_timer
move_bullet10_13:
	    make_text_macro ' ', area, 425, 125, 008000h, 0
    	jmp evt_timer
		
move_bullet_14:
	   make_bullet ' ', area, 450, 400
    	jmp evt_timer
delete7:
    destroy_scut ' ', area, 450, 350
move_bullet1_14:
	    make_bullet ' ', area, 450, 370
    	jmp evt_timer
move_bullet2_14:
	    make_bullet ' ', area, 450, 340
    	jmp evt_timer
move_bullet3_14:
	    make_bullet ' ', area, 450, 310
    	jmp evt_timer
move_bullet4_14:
	    make_bullet ' ', area, 450, 280
    	jmp evt_timer
move_bullet5_14:
	    destroy_extra ' ', area, 435, 260
		
		make_text_macro '9', area, 255, 100, 0DEB887h, 0
		cmp counter, 300
		jl score1
		cmp counter, 600
		jl score2
		cmp counter, 900
		jl score3
		cmp counter, 1200
		jl score4
		cmp counter, 1500
		jl score5
    	jmp evt_timer
		
move_bullet_15:
	   make_bullet ' ', area, 470, 400
    	jmp evt_timer
move_bullet1_15:
        destroy_scut ' ', area, 470, 350
	    make_bullet ' ', area, 470, 370
    	jmp evt_timer
move_bullet2_15:
	    make_bullet ' ', area, 470, 340
    	jmp evt_timer
move_bullet3_15:
	    make_bullet ' ', area, 470, 310
    	jmp evt_timer
move_bullet4_15:
	    make_bullet ' ', area, 470, 280
    	jmp evt_timer
move_bullet5_15:
	    make_bullet ' ', area, 470, 250
    	jmp evt_timer
move_bullet6_15:
	    make_bullet ' ', area, 470, 220
    	jmp evt_timer
move_bullet7_15:
	    make_bullet ' ', area, 470, 190
    	jmp evt_timer
move_bullet8_15:
	    make_bullet ' ', area, 470, 160
    	jmp evt_timer
move_bullet9_15:
	    make_bullet ' ', area, 470, 130
    	jmp evt_timer
move_bullet10_15:
    make_text_macro ' ', area, 470, 125, 008000h, 0
	jmp evt_timer

	
score1:
     make_text_macro '0', area, 245, 100, 0DEB887h, 0
     jmp afisare_litere	 
score2:
     make_text_macro '1', area, 245, 100, 0DEB887h, 0
     jmp afisare_litere	
score3:
     make_text_macro '2', area, 245, 100, 0DEB887h, 0
     jmp afisare_litere	
score4:
     make_text_macro '3', area, 245, 100, 0DEB887h, 0
     jmp afisare_litere	
score5:
     make_text_macro '4', area, 245, 100, 0DEB887h, 0
     jmp afisare_litere
	
move_extra_down1:;deplasăm în jos lanțul de extratereștrii prin suprascrierea acestuia și ștergerea primelor linii de sus pe care se aflau extratereștrii		
    macro_extra_lant extra_symbol, area, button_x+button_size-30, button_y+10, 300
    down_extra ' ', area, button_x+button_size-20, button_y+40
    jmp evt_timer
move_extra_down2:		
    macro_extra_lant extra_symbol, area, button_x+button_size-30, button_y+10, 300
    down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
    jmp evt_timer
move_extra_down3:		
    macro_extra_lant extra_symbol, area, button_x+button_size-30, button_y+10, 300
    down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
    jmp evt_timer
move_extra_down4:		
    macro_extra_lant extra_symbol, area, button_x+button_size-30, button_y+10, 300
    down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
    jmp evt_timer
move_extra_down5:		
    down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	down_extra ' ', area, button_x+button_size-20, button_y+160

game_over:;dacă am ajuns aici înseamnă că jocul s-a terminat	
	make_text_macro 'G', area, 280, 285, 0DEB887h, 0
	make_text_macro 'A', area, 290, 285, 0DEB887h, 0
	make_text_macro 'M', area, 300, 285, 0DEB887h, 0
	make_text_macro 'E', area, 310, 285, 0DEB887h, 0
	make_text_macro ' ', area, 320, 285, 0DEB887h, 0
	make_text_macro 'O', area, 330, 285, 0DEB887h, 0
	make_text_macro 'V', area, 340, 285, 0DEB887h, 0
	make_text_macro 'E', area, 350, 285, 0DEB887h, 0
	make_text_macro 'R', area, 360, 285, 0DEB887h, 0
    jmp afisare_litere
	
;etichete pentru deplasarea navei și a extratereștrilor, precum și crearea gloanțelor trase de navă	și deplasarea celor trase de extratereștrii
fail:
		move_ship_left_macro ship_symbol, area, 320, 430
		make_bullet_extra ' ', area, 351, 307
		draw_lines 201, 277, 3, 3, 0FF8C00h
		jmp evt_timer
extra_move1:
    move_extra_left extra_symbol, area, button_x+button_size-60, button_y;se suprascrie lanțul de extratereștrii cu o poziție mai la stânga și în același timp se șterge cea mai din dreapta coloană
	jmp evt_timer
extra_move1_1:
    move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	jmp evt_timer
extra_move1_2:
    move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	jmp evt_timer
extra_move1_3:
    move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	jmp evt_timer
extra_move1_4:
    move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	jmp evt_timer
	
fail1:
		move_ship_left_macro ship_symbol, area, 300, 430
		make_bullet_extra ' ', area, 351, 337
		make_bullet_extra ' ', area, 201, 307
		 jmp evt_timer
extra_move2:
    move_extra_right extra_symbol, area, 165, button_y;se suprascrie lanțul de extratereștrii în poziția inițială și în același timp se șterge cea mai din stânga coloană
	jmp evt_timer
extra_move2_1:
    move_extra_right extra_symbol, area, 165, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	jmp evt_timer
extra_move2_2:
    move_extra_right extra_symbol, area, 165, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	jmp evt_timer
extra_move2_3:
    move_extra_right extra_symbol, area, 165, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	jmp evt_timer
extra_move2_4:
    move_extra_right extra_symbol, area, 165, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	jmp evt_timer

fail2:
		move_ship_left_macro ship_symbol, area, 280, 430
		destroy_scut ' ', area, 350, 350
		make_bullet_extra ' ', area, 351, 367
		make_bullet_extra ' ', area, 201, 337
		jmp evt_timer
extra_move3:
    move_extra_right extra_symbol, area, 195, button_y;se suprascrie lanțul de extratereștrii cu o poziție mai la dreapta și în același timp se șterge cea mai din stânga coloană
	jmp evt_timer
extra_move3_1:
    move_extra_right extra_symbol, area, 195, button_y
	down_extra ' ', area, button_x+button_size-15, button_y+40
	jmp evt_timer
extra_move3_2:
    move_extra_right extra_symbol, area, 195, button_y
	down_extra ' ', area, button_x+button_size-15, button_y+40
	down_extra ' ', area, button_x+button_size-15, button_y+70
	jmp evt_timer
extra_move3_3:
    move_extra_right extra_symbol, area, 195, button_y
	down_extra ' ', area, button_x+button_size-15, button_y+40
	down_extra ' ', area, button_x+button_size-15, button_y+70
	down_extra ' ', area, button_x+button_size-15, button_y+100
	jmp evt_timer
extra_move3_4:
    move_extra_right extra_symbol, area, 195, button_y
	 down_extra ' ', area, button_x+button_size-15, button_y+40
	down_extra ' ', area, button_x+button_size-15, button_y+70
	down_extra ' ', area, button_x+button_size-15, button_y+100
	down_extra ' ', area, button_x+button_size-15, button_y+130
	jmp evt_timer
	
fail3:
		move_ship_left_macro ship_symbol, area, 260, 430
		make_bullet_extra ' ', area, 351, 397
		destroy_scut ' ', area, 195, 350
		make_bullet_extra ' ', area, 201, 367
		jmp evt_timer
extra_move4:
    move_extra_left extra_symbol, area, button_x+button_size-30, button_y
	jmp evt_timer
extra_move4_1:
    move_extra_left extra_symbol, area, button_x+button_size-30, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	jmp evt_timer
extra_move4_2:
    move_extra_left extra_symbol, area, button_x+button_size-30, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	jmp evt_timer
extra_move4_3:
    move_extra_left extra_symbol, area, button_x+button_size-30, button_y
	down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	jmp evt_timer
extra_move4_4:
    move_extra_left extra_symbol, area, button_x+button_size-30, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	jmp evt_timer

fail4:
		move_ship_left_macro ship_symbol, area, 240, 430
		make_bullet_extra ' ', area, 351, 427
		make_bullet_extra ' ', area, 201, 397
	jmp evt_timer
extra_move5:
     move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	 jmp evt_timer
extra_move5_1:
     move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	 jmp evt_timer
extra_move5_2:
     move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	 jmp evt_timer
extra_move5_3:
     move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	 jmp evt_timer
extra_move5_4:
     move_extra_left extra_symbol, area, button_x+button_size-60, button_y
	  down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	 jmp evt_timer
	 
fail5:
		move_ship_left_macro ship_symbol, area, 220, 430
		make_bullet_extra ' ', area, 201, 427
		make_text_macro ' ', area, 346, 410, 008000h, 0
	jmp evt_timer
extra_move6: 
     move_extra_right extra_symbol, area, 165, button_y
	 jmp evt_timer
extra_move6_1: 
     move_extra_right extra_symbol, area, 165, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	 jmp evt_timer
extra_move6_2: 
     move_extra_right extra_symbol, area, 165, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	 jmp evt_timer
extra_move6_3: 
     move_extra_right extra_symbol, area, 165, button_y
	 down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	 jmp evt_timer
extra_move6_4: 
     move_extra_right extra_symbol, area, 165, button_y
	  down_extra ' ', area, button_x+button_size-20, button_y+40
	down_extra ' ', area, button_x+button_size-20, button_y+70
	down_extra ' ', area, button_x+button_size-20, button_y+100
	down_extra ' ', area, button_x+button_size-20, button_y+130
	 jmp evt_timer
	 
fail6:
		move_ship_left_macro ship_symbol, area, 200, 430
		make_text_macro ' ', area, 196, 410, 008000h, 0
		make_text_macro ' ', area, 450, 105, 008000h, 0
		make_text_macro ' ', area, 460, 105, 008000h, 0
	jmp evt_timer
	
fail7:
		move_ship_left_macro ship_symbol, area, 180, 430
		draw_lines 261, 277, 3, 3, 0FF8C00h
		draw_lines 381, 277, 3, 3, 0FF8C00h
		jmp evt_timer  
		
fail8:
		move_ship_right_macro ship_symbol, area, 160, 430
		make_bullet_extra ' ', area, 261, 307
		make_bullet_extra ' ', area, 381, 307
		jmp evt_timer
		
fail9:
		move_ship_right_macro ship_symbol, area, 180, 430
		make_bullet_extra ' ', area, 261, 337
		make_bullet_extra ' ', area, 381, 337
		jmp evt_timer
		
fail10:
		move_ship_right_macro ship_symbol, area, 200, 430
		destroy_scut ' ', area, 255, 350
		make_bullet_extra ' ', area, 261, 367
		destroy_scut ' ', area, 380, 350
		make_bullet_extra ' ', area, 381, 367
	   jmp evt_timer
	   
fail11:
		move_ship_right_macro ship_symbol, area, 220, 430
		make_bullet_extra ' ', area, 261, 397
		make_bullet_extra ' ', area, 381, 397
		jmp evt_timer
		
fail12:
		move_ship_right_macro ship_symbol, area, 240, 430
		make_bullet_extra ' ', area, 261, 427
		make_bullet_extra ' ', area, 381, 427
		jmp evt_timer
		
fail13:
		move_ship_right_macro ship_symbol, area, 260, 430
		make_text_macro ' ', area, 256, 410, 008000h, 0
		make_text_macro ' ', area, 376, 410, 008000h, 0
		draw_lines 291, 277, 3, 3, 0FF8C00h
		draw_lines 321, 277, 3, 3, 0FF8C00h
		make_text_macro ' ', area, 425, 105, 008000h, 0
		make_text_macro ' ', area, 435, 105, 008000h, 0
		jmp evt_timer
		
fail14:
		move_ship_right_macro ship_symbol, area, 280, 430
		make_bullet_extra ' ', area, 291, 307
		make_bullet_extra ' ', area, 321, 307
		jmp evt_timer
		
fail15:
		move_ship_right_macro ship_symbol, area, 300, 430
		make_bullet_extra ' ', area, 291, 337
		make_bullet_extra ' ', area, 321, 337
	    jmp evt_timer
	
fail16:
		move_ship_right_macro ship_symbol, area, 320, 430
		destroy_scut ' ', area, 290, 350
		make_bullet_extra ' ', area, 291, 367
		make_bullet_extra ' ', area, 321, 367
		jmp evt_timer
		
fail17:
		move_ship_right_macro ship_symbol, area, 340, 430
		make_bullet_extra ' ', area, 291, 397
		make_bullet_extra ' ', area, 321, 397
	    jmp evt_timer
		
fail18:
		move_ship_right_macro ship_symbol, area, 360, 430
		make_bullet_extra ' ', area, 291, 427
		make_bullet_extra ' ', area, 321, 427
		jmp evt_timer
		
fail19:
		move_ship_right_macro ship_symbol, area, 380, 430
		make_text_macro ' ', area, 286, 410, 008000h, 0
		make_text_macro ' ', area, 316, 410, 008000h, 0
		draw_lines 231, 277, 3, 3, 0FF8C00h
		draw_lines 411, 277, 3, 3, 0FF8C00h
		jmp evt_timer
		
fail20:
		move_ship_right_macro ship_symbol, area, 400, 430
		make_bullet_extra ' ', area, 231, 307
		make_bullet_extra ' ', area, 411, 307
	    jmp evt_timer
		
fail21:
		move_ship_right_macro ship_symbol, area, 420, 430
		make_bullet_extra ' ', area, 231, 307
		make_bullet_extra ' ', area, 411, 307
		jmp evt_timer
		
fail22:
		move_ship_right_macro ship_symbol, area, 440, 430
		make_bullet_extra ' ', area, 231, 337
		make_bullet_extra ' ', area, 411, 337
		draw_lines 441, 277, 3, 3, 0FF8C00h
	    jmp evt_timer
		
fail23:
		move_ship_left_macro ship_symbol, area, 460, 430
		make_bullet_extra ' ', area, 231, 367
		make_bullet_extra ' ', area, 411, 367
		make_bullet_extra ' ', area, 441, 307
		jmp evt_timer
		
fail24:
		move_ship_left_macro ship_symbol, area, 440, 430
		make_bullet_extra ' ', area, 231, 397
		make_bullet_extra ' ', area, 411, 397
		make_bullet_extra ' ', area, 441, 337
		jmp evt_timer
		
fail25:
		move_ship_left_macro ship_symbol, area, 420, 430
		make_bullet_extra ' ', area, 231, 427
		make_bullet_extra ' ', area, 411, 427
		destroy_scut ' ', area, 440, 350
		make_bullet_extra ' ', area, 441, 367
		jmp evt_timer
		
fail26:
		move_ship_left_macro ship_symbol, area, 400, 430
		make_text_macro ' ', area, 226, 410, 008000h, 0
		make_text_macro ' ', area, 406, 410, 008000h, 0
		make_bullet_extra ' ', area, 441, 397
		make_text_macro ' ', area, 400, 105, 008000h, 0
		make_text_macro ' ', area, 410, 105, 008000h, 0
		jmp evt_timer
		
fail27:
		move_ship_left_macro ship_symbol, area, 380, 430
		make_bullet_extra ' ', area, 441, 427
		jmp evt_timer
		
fail28:
		move_ship_left_macro ship_symbol, area, 360, 430
		make_text_macro ' ', area, 436, 410, 008000h, 0
	    jmp evt_timer	

	
evt_timer:
	inc counter
	inc counterok
    inc counterok1
	inc counterok2
	inc counterok3
    inc counterok4
	inc counterok5
	inc counterok6
    inc counterok7
	inc counterok8
	inc counterok9
    inc counterok10
	inc counterok11
	inc counterok12
    inc counterok13
	inc counterok14
	inc counterok15
    
	inc counter_ship0
	inc counter_ship1
	inc counter_ship2
	
   cmp counter, 2
   je start_1;la momentul acesta afișăm majoritatea lucrurilor în fereastră
   cmp counter, 9
   je extra_move1 
   cmp counter, 18
   je extra_move2  
   cmp counter, 27
   je extra_move3 
   cmp counter, 36
   je extra_move4 
   cmp counter, 45
   je extra_move5 
   cmp counter, 54
   je extra_move6 
   
   cmp counter, 309
   je extra_move1_1 
   cmp counter, 318
   je extra_move2_1  
   cmp counter, 327
   je extra_move3_1 
   cmp counter, 336
   je extra_move4_1 
   cmp counter, 345
   je extra_move5_1 
   cmp counter, 354
   je extra_move6_1 
   
   cmp counter, 609
   je extra_move1_2 
   cmp counter, 618
   je extra_move2_2  
   cmp counter, 627
   je extra_move3_2 
   cmp counter, 636
   je extra_move4_2 
   cmp counter, 645
   je extra_move5_2 
   cmp counter, 654
   je extra_move6_2 
   
   cmp counter, 909
   je extra_move1_3 
   cmp counter, 918
   je extra_move2_3  
   cmp counter, 927
   je extra_move3_3 
   cmp counter, 936
   je extra_move4_3 
   cmp counter, 945
   je extra_move5_3 
   cmp counter, 954
   je extra_move6_3 
   
   cmp counter, 1209
   je extra_move1_4 
   cmp counter, 1218
   je extra_move2_4  
   cmp counter, 1227
   je extra_move3_4 
   cmp counter, 1236
   je extra_move4_4 
   cmp counter, 1245
   je extra_move5_4 
   cmp counter, 1254
   je extra_move6_4 

    cmp counter, 300
    je move_extra_down1
	cmp counter, 600
    je move_extra_down2
	cmp counter, 900
    je move_extra_down3
	cmp counter, 1200
    je move_extra_down4
	cmp counter, 1500
    je move_extra_down5
	jg afisare_litere
	
   cmp counter_ship0, 310
   je game_over
   cmp counter_ship1, 310
   je game_over
   jg afisare_litere
   cmp counter_ship2, 310
   je game_over
   jg afisare_litere
   
   mov eax, counter
   mov ebx, 300
   div  ebx
   cmp edx, 1
   je start_game
   cmp edx, 10
   je fail
   cmp edx, 20
   je fail1
   cmp edx, 30
   je fail2
   cmp edx, 40
   je fail3
   cmp edx, 50
   je fail4
   cmp edx, 60
   je fail5
   cmp edx, 70
   je fail6
   cmp edx, 80
   je fail7
   cmp edx, 90
   je fail8
   cmp edx, 100
   je fail9
   cmp edx, 110
   je fail10
   cmp edx, 120
   je fail11
   cmp edx, 130
   je fail12
   cmp edx, 140
   je fail13
   cmp edx, 150
   je fail14
   cmp edx, 160
   je fail15
   cmp edx, 170
   je fail16
   cmp edx, 180
   je fail17
   cmp edx, 190
   je fail18
   cmp edx, 200
   je fail19
   cmp edx, 210
   je fail20
   cmp edx, 220
   je fail21
   cmp edx, 230
   je fail22
   cmp edx, 240
   je fail23
   cmp edx, 250
   je fail24
   cmp edx, 260
   je fail25
   cmp edx, 270
   je fail26
   cmp edx, 280
   je fail27
   cmp edx, 290
   je fail28
   
evt_timer2:
   cmp counterok, 10
   je move_bullet
   cmp counterok, 20
   je move_bullet1
   cmp counterok, 30
   je move_bullet2
   cmp counterok, 40
   je move_bullet3
   cmp counterok, 50
   je move_bullet4
   cmp counterok, 60
   je move_bullet5
   
   cmp counterok1, 10
   je move_bullet_1
   cmp counterok1, 20
   je move_bullet1_1
   cmp counterok1, 30
   je move_bullet2_1
   cmp counterok1, 40
   je move_bullet3_1
   cmp counterok1, 50
   je move_bullet4_1
   cmp counterok1, 60
   je move_bullet5_1
   cmp counterok1, 70
   je move_bullet6_1
   cmp counterok1, 80
   je move_bullet7_1
   cmp counterok1, 90
   je move_bullet8_1
   cmp counterok1, 100
   je move_bullet9_1
   cmp counterok1, 110
   je move_bullet10_1
   
   cmp counterok2, 10
   je move_bullet_2
   cmp counterok2, 20
   je delete1
   cmp counterok2, 30
   je move_bullet2_2
   cmp counterok2, 40
   je move_bullet3_2
   cmp counterok2, 50
   je move_bullet4_2
   cmp counterok2, 60
   je move_bullet5_2
   
   cmp counterok3, 10
   je move_bullet_3
   cmp counterok3, 20
   je delete2
   cmp counterok3, 30
   je move_bullet2_3
   cmp counterok3, 40
   je move_bullet3_3
   cmp counterok3, 50
   je move_bullet4_3
   cmp counterok3, 60
   je move_bullet5_3
   
   cmp counterok4, 10
   je move_bullet_4
   cmp counterok4, 20
   je move_bullet1_4
   cmp counterok4, 30
   je move_bullet2_4
   cmp counterok4, 40
   je move_bullet3_4
   cmp counterok4, 50
   je move_bullet4_4
   cmp counterok4, 60
   je move_bullet5_4
   cmp counterok4, 70
   je move_bullet6_4
   cmp counterok4, 80
   je move_bullet7_4
   cmp counterok4, 90
   je move_bullet8_4
   cmp counterok4, 100
   je move_bullet9_4
   cmp counterok4, 110
   je move_bullet10_4
   
   cmp counterok5, 10
   je move_bullet_5
   cmp counterok5, 20
   je move_bullet1_5
   cmp counterok5, 30
   je move_bullet2_5
   cmp counterok5, 40
   je move_bullet3_5
   cmp counterok5, 50
   je move_bullet4_5
   cmp counterok5, 60
   je move_bullet5_5

   cmp counterok6, 10
   je move_bullet_6
   cmp counterok6, 20
   je move_bullet1_6
   cmp counterok6, 30
   je move_bullet2_6
   cmp counterok6, 40
   je move_bullet3_6
   cmp counterok6, 50
   je move_bullet4_6
   cmp counterok6, 60
   je move_bullet5_6
 
   cmp counterok7, 10
   je move_bullet_7
   cmp counterok7, 20
   je delete3
   cmp counterok7, 30
   je move_bullet2_7
   cmp counterok7, 40
   je move_bullet3_7
   cmp counterok7, 50
   je move_bullet4_7
   cmp counterok7, 60
   je move_bullet5_7
   cmp counterok7, 70
   je move_bullet6_7
   cmp counterok7, 80
   je move_bullet7_7
   cmp counterok7, 90
   je move_bullet8_7
   cmp counterok7, 100
   je move_bullet9_7
   cmp counterok7, 110
   je move_bullet10_7
   
   cmp counterok8, 10
   je move_bullet_8
   cmp counterok8, 20
   je delete4
   cmp counterok8, 30
   je move_bullet2_8
   cmp counterok8, 40
   je move_bullet3_8
   cmp counterok8, 50
   je move_bullet4_8
   cmp counterok8, 60
   je move_bullet5_8
   cmp counterok8, 70
   je move_bullet6_8
   cmp counterok8, 80
   je move_bullet7_8
   cmp counterok8, 90
   je move_bullet8_8
   cmp counterok8, 100
   je move_bullet9_8
   cmp counterok8, 110
   je move_bullet10_8

   cmp counterok9, 10
   je move_bullet_9
   cmp counterok9, 20
   je delete5
   cmp counterok9, 30
   je move_bullet2_9
   cmp counterok9, 40
   je move_bullet3_9
   cmp counterok9, 50
   je move_bullet4_9
    cmp counterok9, 60
   je move_bullet5_9

   cmp counterok10, 10
   je move_bullet_10
   cmp counterok10, 20
   je delete6
   cmp counterok10, 30
   je move_bullet2_10
   cmp counterok10, 40
   je move_bullet3_10
   cmp counterok10, 50
   je move_bullet4_10
   cmp counterok10, 60
   je move_bullet5_10
   cmp counterok10, 70
   je move_bullet6_10
   cmp counterok10, 80
   je move_bullet7_10
   cmp counterok10, 90
   je move_bullet8_10
   cmp counterok10, 100
   je move_bullet9_10
   cmp counterok10, 110
   je move_bullet10_10

   cmp counterok11, 10
   je move_bullet_11
   cmp counterok11, 20
   je move_bullet1_11
   cmp counterok11, 30
   je move_bullet2_11
   cmp counterok11, 40
   je move_bullet3_11
   cmp counterok11, 50
   je move_bullet4_11
   cmp counterok11, 60
   je move_bullet5_11
   
   cmp counterok12, 10
   je move_bullet_12
   cmp counterok12, 20
   je move_bullet1_12
   cmp counterok12, 30
   je move_bullet2_12
   cmp counterok12, 40
   je move_bullet3_12
   cmp counterok12, 50
   je move_bullet4_12
   cmp counterok12, 60
   je move_bullet5_12
   
   cmp counterok13, 10
   je move_bullet_13
   cmp counterok13, 20
   je move_bullet1_13
   cmp counterok13, 30
   je move_bullet2_13
   cmp counterok13, 40
   je move_bullet3_13
   cmp counterok13, 50
   je move_bullet4_13
   cmp counterok13, 60
   je move_bullet5_13
   cmp counterok13, 70
   je move_bullet6_13
   cmp counterok13, 80
   je move_bullet7_13
   cmp counterok13, 90
   je move_bullet8_13
   cmp counterok13, 100
   je move_bullet9_13
   cmp counterok13, 110
   je move_bullet10_13
  
   cmp counterok14, 10
   je move_bullet_14
   cmp counterok14, 20
   je delete7
   cmp counterok14, 30
   je move_bullet2_14
   cmp counterok14, 40
   je move_bullet3_14
   cmp counterok14, 50
   je move_bullet4_14
   cmp counterok14, 60
   je move_bullet5_14

   cmp counterok15, 10
   je move_bullet_15
   cmp counterok15, 20
   je move_bullet1_15
   cmp counterok15, 30
   je move_bullet2_15
   cmp counterok15, 40
   je move_bullet3_15
   cmp counterok15, 50   
   je move_bullet4_15
   cmp counterok15, 60
   je move_bullet5_15
   cmp counterok15, 70
   je move_bullet6_15
   cmp counterok15, 80
   je move_bullet7_15
   cmp counterok15, 90
   je move_bullet8_15
   cmp counterok15, 100
   je move_bullet9_15
   cmp counterok15, 110
   je move_bullet10_15
   
   
afisare_litere:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start