. data
      cheie : . asciiz " SECRET "
      mesajul : . asciiz " COOPTAT "
      matrice : . space 25        # matricea 5 x5 ( liniara )
      frecv : . space 26          # vector de frecventa
      procesat : . space 167      # vectorul in care o sa punem in perechi mesajul si adaugam X-urile marimea lui variaza de dimensiunea mesajului
      encriptat: .space 167       # vectorul cu mesajul in care o sa apara mesajul encriptat
      decriptat: .space 167       # vectorul cu mesajul in care o sa apara mesajul decriptat
      newline : . asciiz " \ n "

. text
. global main

main :
      la t0 , frecv             # t0 -> adresa frecv
      li t1 , 26                # t1 = 26 litere
      li t2 , 0                 # t2 = 0 ( contor )

      #Vector de frecventa

init_frecv :
        sb zero , 0( t0 )                      # frecv [ i ] = 0
        addi t0 , t0 , 1
        addi t2 , t2 , 1
        blt t2 , t1 , init_frecv               # daca contorul < t1 (=26 numarul total de litere din alfabet ) reia bucla
              # altfel trecem mai departe

      la s0 , cheie                  # s0 -> pointer adresa cheie
      la s1 , matrice                # s1 -> adresa baza matrice
      li s2 , 0                      # s2 = 0 ( pozitie curenta )

cheie_loop :
        lb t0 , 0( s0 )                          # t0 = litera curenta din CHEIE
        beqz t0 , start_alfabet                  # daca ’\0 ’ , trecem la completarea matricei cu
        literele nefolosite din alfabet
        
        # daca litera == ’J ’ , o inlocuim cu ’I ’
        li t1 , ’J ’                   # t1 = J
        li t2 , ’I ’                   # t2 = I
        beq t0 , t1 , inlocuire        # t0 ( litera curenta ) == t1 ( j ) facem salt
        j verif_frecv

inlocuire :
        mv t0 , t2 # t2 era I asa ca t0 devine ’I ’

verif_frecv :

        addi t3 , t0 , -’A ’         # t3 ( index ) = litera curenta - ’A ’ calculez indexul unei litere in alfabet
        la t4 , frecv                # t4 -> pointer adresa vector de frecventa
        add t4 , t4 , t3             # pun in vectorul de frecventa l
        lb t5 , 0( t4 )              # dau load in t5 la primul element din frecv care e 0
        bnez t5 , skip_key           # daca nu e 0 inseamna ca e folosit si sarim
        
        add t6 , s1 , s2             # matrice [ pos ] = litera
        sb t0 , 0( t6 )              # dau store la t5 in adresa primul element din frecv
        
        li t5 , 1                    # frecv [ index ] = 1
        sb t5 , 0( t4 )              # dau store la t5 in adresa primul element din frecv
        
        addi s2 , s2 , 1             # pos ++

skip_key :

        addi s0 , s0 , 1            # s0 ++ mergem la urmatorea casuta
        j cheie_loop                # facem salt si trecem la urmatoare litera din cheie

# Completare alfabet

start_alfabet :
        li t0 , ’A ’                # incarca prima litera din alfabet ’A ’ in t0 pentru a incape verificarea si completarea

 copletare_alfabet :
        li t1 , ’Z ’                    # t1 = Z pentru a putea forma conditie de iesit
        bgt t0 , t1 , inchidem_alf          # daca am trecut de Z , gata
        
        li t2 , ’J ’                    # punem in t2 j ca sa il putem compara
        beq t0 , t2 , trecem_peste      # daca t0 ( litera curenta ) este egal cu t2 , sarim peste J
        
        addi t3 , t0 , -’A ’            # calculez indexul unei litere in alfabet
        la t4 , frecv                   # t4 -> pointer adresa vector de frecventa
        add t4 , t4 , t3                # pun in vectorul de frecventa l
        lb t5 , 0( t4 )                 # dau load in t5 la primul element din frecv care e
        bnez t5 , trecem_peste          # daca nu e 0 inseamna ca e folosit si sarim
        
        add t6 , s1 , s2                # matrix [ pos ] = litera
        sb t0 , 0( t6 )                 # dau store la t0 ( litera curenta ) in matrix [ pos ]
        
        li t5 , 1                       # frecv [ index ] = 1
        sb t5 , 0( t4 )                 # dau store la t5 in adresa primul element din frecv
        
        addi s2 , s2 , 1                # pos ++

trecem_peste :
        addi t0 , t0 , 1                # t0 ++
        j copletare_alfabet             # facem salt si trecem la urmatoare litera dinalfabet

inchidem_alf :                           # functia care ca opreasca loop ul si sa continue codul    
       li t1 , ’Z’                      # am pus o instructiune cere nu face nimic diferit ca sa nu imi dea eroare 

  #Procesare mesaj
preprocess_mesaj :
        la t0 , mesaj         # t0 -> pointer mesaj original
        la t1 , procesat       # t1 -> pointer mesaj procesat

citire_primul_caracter :
        lb t2 , 0( t0 )       # t2 = caracter curent
        beqz t2 , inchidem_ch     # daca e ’\0 ’ , iesim
        
        
        li t3 , ’ ’           # daca e spatiu , il ignoram
        beq t2 , t3 , skip_primul
        
        li t3 , ’J ’                          # folosim aceeasi idee ca la cheie pt
        inlocuire J
        li t4 , ’I ’
        beq t2 , t3 , inlocure_j_mesaj1       # daca e J , il inlocuim cu I
        j primul_ok

inlocure_j_mesaj1 :
      mv t2 , t4                              # t2 = ’I ’

primul_ok :
        addi t0 , t0 , 1                      # avansam dupa prima litera

citire_al_doilea_caracter :                   # identic cu citirea primului din pereche
        lb t5 , 0( t0 )                       # t5 = a doua litera
        beqz t5 , ultima_litera_singura       # daca s - a terminat sirul
        
        li t3 , ’ ’                           # ignoram spatiile
        beq t5 , t3 , skip_al_doilea
        
        li t3 , ’J ’                           # J -> I
        beq t5 , t3 , inlocure_j_mesaj2
        j comparare

inlocure_j_mesaj2 :
        mv t5 , t4

comparare :
        beq t2 , t5 , inserare_X               # daca literele sunt egale inseram X intre ele
        
        sb t2 , 0( t1 )                        # altfel le scriem pe amandoua
        sb t5 , 1( t1 )
        addi t1 , t1 , 2
        addi t0 , t0 , 1                       # consumam a doua litera
        j citire_primul_caracter

inserare_X :
        # scriem litera + X
        sb t2 , 0( t1 )
        li t6 , ’X ’
        sb t6 , 1( t1 )
        addi t1 , t1 , 2
        # NU consumam a doua litera
        j citire_primul_caracter

skip_primul :
        addi t0 , t0 , 1
        j citire_primul_caracter

skip_al_doilea :
        addi t0 , t0 , 1 # incrementam cu 1
        j citire_al_doilea_caracter # trecem sa citim al doilea caracter din pereche

ultima_litera_singura :

        sb t2 , 0( t1 )         # a ramas o singura litera -> adaugam X
        
        li t6 , ’X ’
        sb t6 , 1( t1 )
        addi t1 , t1 , 2
        j inchidem_ch

inchidem_ch :
        sb zero , 0( t1 )       # terminator de sir
        ret

#Partea de codare 

encriptare_mesaj:
    la t0, procesat       # t0 = pointer adresa mesaj procesat
    la t1, encriptat      # t1 = pointer adresa mesaj criptat

encriptare_loop:
    lb a0, 0(t0)               # a0 = prima litera
    beqz a0, incheiere_enc     # daca a0 == '\0', iesim din bucla
    lb a1, 1(t0)               # a1 = a doua litera

    # apel functie care cripteaza o pereche
    call encriptare_perechi     # returneaza a2, a3

    sb a2, 0(t1)          # scriem prima litera criptata
    sb a3, 1(t1)          # scriem a doua litera criptata

    addi t0, t0, 2        # urmatoarea pereche
    addi t1, t1, 2
    j encriptare_loop     # salt la inceputul loop-ului

incheiere_enc:
    sb zero, 0(t1)        #  am terminat ecriptarea si punem terminator de sir

#encriptare_perechi:
    # a0 = litera 1 din pereche
    # a1 = litera 2 din pereche

    # cautam pozitia primei litere
    # call find_position    # obtinem lin1, col1

    # cautam pozitia celei de-a doua litere
    # call find_position    # obtinem lin2, col2

    # daca sunt pe aceeasi linie mutam la dreapta
    # daca sunt pe aceeasi coloana  mutam in jos
    # altfel: dreptunghi (schimb coloanele)
    # citim noile litere din matrice
    # le punem in a2 si a3
    #ret

#find_position:

    # parcurgem toata matricea intr-un loop
    # folosim beq pentru a cauta litera pe care o cautam
    # daca e aia care trebuie luam indexul si cu ajutorul formulei de mai sus
            # calculam lin si col  si iesim din bucla     (index = lin * 5 + col)
    #daca nu e trecem la urmatoarea litera pana terminam alfabetul
    # conditie de intoarcere la inceputulo buclei de find_position

#Parte de decriptare mesaj
     # asemănătoare cu codificarea doar că in ordine inversă


print_mesaj :
        la a0 , encriptat      # adresa mesajului codat
        li a7 , 4              # syscall : print string
        ecall


        la a0 , decriptat      # adresa mesajului decodificat
        li a7 , 4              # syscall : print string
        ecall
       


