#
# IAC 2023/2024 k-means
# 
# Grupo: 21
# Campus: Taguspark
#
# Autores:
# 103258, Ana Caldeira
# 110321, Tiago Fernandes
# 109280, Dinis Esteves
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 6,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,9, 3,8, 0,10, 4,10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0 
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 0, 20, 0,10
k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    

# Vetor auxiliar para a função nearest cluster,
#guarda a distância de um punto aos centroids
distToClus:    .word 0, 0, 0


#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster
    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    lw a0, k
    la a1, centroids
    jal cleanScreen
    jal initializeCentroids
    jal printCentroids
    
    
    
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecrã
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
# s0 (Primeiro ponto) | s1 (Ultimo Ponto) | s2 (Cor branca)
    
    # push das variaveis usadas para o stack
    addi sp, sp, -12
    sw s0, (0)sp
    sw s1, (4)sp
    sw s2, (8)sp
    
    # carrega os valores para as variaveis
    li s0, LED_MATRIX_0_BASE
    li s1, LED_MATRIX_0_SIZE
    add s1, s0, s1
    li s2, white
    
    clean_loop:
        sw s2, (0)s0                # pinta de branco
        addi s0, s0, 4              # anda um ponto para a frente
        ble s0, s1, clean_loop      # verifica se chagamos ao fim
    
    # pop das variaveis
    lw s2, (8)sp
    lw s1, (4)sp
    lw s0, (0)sp
    addi sp, sp, 12
    
    jr ra

### cleanPoints
# Limpa os pontos do cluster e dos centroids
# Argumentos: nenhum
# Retorno: nenhum

cleanPoints:
    
    # push
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw t0, 16(sp)
    sw ra, 20(sp)
    sw a2, 24(sp)
    
    
    # inicializar variaveis
    lw s0, k
    la s1, centroids
    lw s2, n_points
    la s3, points
    li a2, white
    li t0, 0
    
    loop_centroids:
        lw a0, 0(s1)
        lw a1, 4(s1)    
        
        jal printPoint
        
        addi t0, t0, 1
        addi s1, s1, 8
        
        bne s0, t0, loop_centroids
        li t0, 0
        
    loop_points:
        lw a0, 0(s3)
        lw a1, 4(s3)    
        
        jal printPoint
        
        addi t0, t0, 1
        addi s3, s3, 8
        
        bne s2, t0, loop_points
    
    lw a2, 24(sp)
    lw ra, 20(sp)
    lw t0, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    
    addi sp, sp, 28
    
    jr ra
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # POR IMPLEMENTAR (1a e 2a parte)
        
        # guarda no stack
        addi sp, sp, -4
        sw ra, 0(sp)
        
        # inicia as variaveis
        lw a2, colors
        la t0, points
        li t4, 0    # iterator i
        lw t1, n_points
        
    loop_printClusters:
        # load do x e do y
        lw a0, 0(t0)
        lw a1, 4(t0)
        
        # printa o ponto
        jal printPoint
        
        # atualiza iterador e a address
        addi t4, t4, 1
        addi t0, t0, 8
        
        bne t1, t4, loop_printClusters
        
        # pop das variaveis
        lw ra, 0(sp)
        addi sp, sp, 4
        
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    
        # push das variaveis
        addi sp, sp, -4
        sw ra, 0(sp)
        
        # inicializar variaveis
        li a2, black        
        la t0, centroids
        li t4, 0 # iterador i
        lw t1, k
        
    loop_printCentroids:
        # load de x e y
        lw a0, 0(t0)
        lw a1, 4(t0)
        
        # printa o ponto
        jal printPoint
        
        # atualiza as variaveis
        addi t4, t4, 1
        addi t0, t0, 8
        
        bne t1, t4, loop_printCentroids
        
        # pop das variaveis
        lw ra, 0(sp)
        addi sp, sp, 4
        
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    
    # inicia variaveis
    la t0, points
    lw t1, n_points
    li t2, 0 # iterador i
    
    loop_calculateCentroids:
        
        # push das variaveis
        lw t3, 0(t0)
        lw t4, 4(t0)
        
        # adiciona o x e o y atuais às variaveis de soma
        add t5, t5, t3
        add t6, t6, t4
        
        # atualiza contador e address
        addi t0, t0, 8
        addi t2, t2, 1
        
        bne t2, t1, loop_calculateCentroids
        
    # divide pelo numero de pontos ( aka medias)
    div t5, t5, t1
    div t6, t6, t1
    
    # atualiza o vetor centroids
    la t2, centroids
    sw t5, 0(t2)
    sw t6, 4(t2)
    
    jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    
    addi sp, sp, -8
    sw ra, 0(sp)

    #1. Coloca k=1 (caso nao esteja a 1)
    # POR IMPLEMENTAR (1a parte)
    
    # guardar o valor anterior de k
    la s0, k
    lw t0, 0(s0)
    sw t0, 4(sp)
    
    # colocar k a 1
    li t0, 1
    sw t0, 0(s0)
    
    #2. cleanScreen
    # POR IMPLEMENTAR (1a parte)
    jal cleanScreen
    #3. printClusters
    # POR IMPLEMENTAR (1a parte)
    jal printClusters
    #4. calculateCentroids
    # POR IMPLEMENTAR (1a parte)
    jal calculateCentroids
    #5. printCentroids
    # POR IMPLEMENTAR (1a parte)
    jal printCentroids
    
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    
    # recolocar o valor de k
    sw t0, 0(s0)
    
    #6. Termina
    jr ra

### initializeCentroids
# Inicializa os valores iniciais do vetor 𝑐𝑒𝑛𝑡𝑟𝑜𝑖𝑑𝑠
# Argumentos:
# a0, a1: k, endereço do vetor centroids
# Retorno: nenhum

initializeCentroids:
    
    # push s0, s1 e s2
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw a3, 12(sp)
    sw ra, 26(sp)
    
    # Passa os argumentos para s0 e s1 & inicializa s2 a 32
    add s0, a0, x0
    add s1, a1, x0
    li s2, 32

    loop_initCentroids:
        # coloca em a0 e a1 valores do epoch (low e high, repetivamente)
        addi a7, x0, 30
        ecall
        
        mv a3, a0
        
        addi a7, x0, 31
        ecall
        
        rem a0, a3, a0
        
        slli a0, a0, 2
        
        # valor random de x
        rem a0, a0, s2
        
        jal abs 
        
        # Salva x no vetor centroids
        sw a0, 0(s1)
    
        # coloca em a0 e a1 valores do epoch (low e high, repetivamente)
        addi a7, x0, 30
        ecall
        
        mv a3, a0
        
        addi a7, x0, 31
        ecall
        
        rem a0, a3, a0
        
        slli a0, a0, 2
    
        # valor random de y
        rem a0, a0, s2 
    
        jal abs 
    
        # Salva y no vetor centroids
        sw a0, 4(s1)
    
        # Anda em uma coordenada (2 indices) no vetor centroids
        addi s1, s1, 8
    
        # decrementa k
        addi s0, s0, -1
    
        # caso ainda não tenha feito para todos os k's repete
        bne s0, x0, loop_initCentroids
    
    # pop
    lw ra, 16(sp)
    lw a3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 20
    
    jr ra 

abs:
    bltz a0, is_negative  # se a0 < 0, salta para 'is_negative'
    jr ra
is_negative:
    neg a0, a0            # se a0 < 0, retorna -a0
    jr ra

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    
    addi sp, sp, -16
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    
    sub a0, a0, a2
    sub t1, a1, a3
    
    jal abs
    mv t0, a0
    
    mv  a0, t1
    jal abs
    
    add a0, a0, t0
    
    lw t1, 8(sp)
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    # push
    addi sp, sp, -28
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)
    sw s0, 20(sp)
    sw s1, 24(sp)
 
    
    la t0, centroids
    lw t1, k
    li t2, 62           # maior distancia de manhattan possivel
    li t3, 0            # iterator
    li t4, 0            #guarda o valor de retorno
    add s0, x0, a0
    add s1, x0, a1
    
    loop_NearestCluster:
        add a0, x0, s0
        add a1, x0, s1
        lw   a2, 0(t0)    # x do centroid
        lw   a3, 4(t0)    # y do centroid
        jal manhattanDistance
        bgt  a0, t2, iterator
        mv   t2, a0       # menor distancia ate ao momento
        mv   t4, t3       # valor de retorno ate ao momento
                
        iterator:
            addi t0, t0, 8
            addi t3, t3, 1
            bne t1, t3, loop_NearestCluster
        
        mv a0, t4
        
    # pop
    lw s1, 24(sp)
    lw s0, 20(sp)
    lw t3, 16(sp)
    lw t2, 12(sp)
    lw t1, 8(sp)
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 28
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra