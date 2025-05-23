; Modelo Unificado de Formigas com Clima, Predadores, Raças e Papéis - NetLogo

; ========================================
; 1. DEFINIÇÕES DE RAÇAS E VARIÁVEIS
; ========================================

; Raças de formigas
breed [ants1 ant1]  ; Colônia vermelha
breed [ants2 ant2]  ; Colônia azul  
breed [ants3 ant3]  ; Colônia verde

; Predadores
breed [anteaters anteater]  ; Predadores nível 1
breed [boas boa]           ; Predadores nível 2

; Variáveis dos patches
patches-own [
  chemical             ; quantidade de feromônio neste patch
  food                 ; quantidade de comida neste patch (0, 1, ou 2)
  nest?                ; verdadeiro nos patches de ninho, falso em outros lugares
  nest-scent           ; número que é maior quanto mais perto do ninho
  food-source-number   ; número (1, 2, ou 3) para identificar as fontes de comida
  obstacle?            ; verdadeiro se o patch for um obstáculo
  toxic?               ; verdadeiro se o patch for tóxico
  toxic-timer          ; contador para controlar quando zonas tóxicas aparecem/desaparecem
  has-food?            ; indica se há comida no patch
  food-amount          ; quantidade específica de comida
  pheromone            ; trilha de feromônio deixada pelas formigas
  colony-scent         ; indica qual colônia marcou este patch
]

; Variáveis das formigas (todas as raças)
turtles-own [
  health               ; saúde da formiga (100 = saudável, 0 = morta)
  strength             ; força da formiga para combate
  role                 ; papel da formiga ("worker", "explorer", "warrior")
  carrying             ; se está carregando comida
  pheromone-trail      ; intensidade do feromônio que deixa
  home-colony          ; qual colônia pertence (1, 2, ou 3)
  target-x             ; coordenada x do alvo
  target-y             ; coordenada y do alvo
]

; Variáveis dos predadores
anteaters-own [
  power                ; poder de ataque do predador
  hunt-timer           ; contador para caça
]

boas-own [
  power                ; poder de ataque do predador
  hunt-timer           ; contador para caça
]

; Variáveis globais
globals [
  current-weather      ; tipo de clima atual
  previous-weather     ; clima anterior
  weather-timer        ; contador para alternar o clima
  ;; diffusion-rate       ; taxa de difusão dos feromônios
  ;; evaporation-rate     ; taxa de evaporação dos feromônios
  ;; population           ; população total de formigas
  colony1-nest-x      ; coordenada x do ninho da colônia 1
  colony1-nest-y      ; coordenada y do ninho da colônia 1
  colony2-nest-x      ; coordenada x do ninho da colônia 2
  colony2-nest-y      ; coordenada y do ninho da colônia 2
  colony3-nest-x      ; coordenada x do ninho da colônia 3
  colony3-nest-y      ; coordenada y do ninho da colônia 3
]
; ========================================
; 2. PROCEDIMENTOS DE SETUP
; ========================================

to setup
  clear-all
  
  ; Inicialização das variáveis globais
  set population 60  ; Total de formigas (20 por colônia)
  set diffusion-rate 50
  set evaporation-rate 10
  
  ; Posições dos ninhos
  set colony1-nest-x -15
  set colony1-nest-y -15
  set colony2-nest-x 15
  set colony2-nest-y -15
  set colony3-nest-x 0
  set colony3-nest-y 15
  
  ; Setup dos componentes
  setup-patches
  setup-nests
  setup-ants
  setup-food
  setup-weather
  
  reset-ticks
end

to setup-patches
  ask patches [
    ; Inicializa todas as propriedades
    set chemical 0
    set food 0
    set nest? false
    set nest-scent 0
    set food-source-number 0
    set obstacle? false
    set toxic? false
    set toxic-timer 0
    set has-food? false
    set food-amount 0
    set pheromone 0
    set colony-scent 0
    
    ; Cria obstáculos aleatórios
    if random-float 100 < 8 [
      set obstacle? true
    ]
    
    ; Calcula nest-scent para cada colônia
    let dist1 distancexy colony1-nest-x colony1-nest-y
    let dist2 distancexy colony2-nest-x colony2-nest-y
    let dist3 distancexy colony3-nest-x colony3-nest-y
    set nest-scent 200 - min (list dist1 dist2 dist3)
    
    ; Configura ninhos
    setup-nest-areas
    
    ; Configura fontes de comida originais
    setup-original-food-sources
    
    ; Recolore o patch
    recolor-patch
  ]
end

to setup-nest-areas
  ; Ninho da colônia 1 (vermelha)
  if (distancexy colony1-nest-x colony1-nest-y) < 4 [
    set nest? true
    set colony-scent 1
  ]
  
  ; Ninho da colônia 2 (azul)
  if (distancexy colony2-nest-x colony2-nest-y) < 4 [
    set nest? true
    set colony-scent 2
  ]
  
  ; Ninho da colônia 3 (verde)
  if (distancexy colony3-nest-x colony3-nest-y) < 4 [
    set nest? true
    set colony-scent 3
  ]
end

to setup-original-food-sources
  ; Fonte de comida 1 (à direita)
  if (distancexy (0.6 * max-pxcor) 0) < 5 [
    set food-source-number 1
    set food one-of [1 2]
    set has-food? true
    set food-amount 8 + random 5
  ]
  
  ; Fonte de comida 2 (inferior esquerda)
  if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5 [
    set food-source-number 2
    set food one-of [1 2]
    set has-food? true
    set food-amount 8 + random 5
  ]
  
  ; Fonte de comida 3 (superior esquerda)
  if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5 [
    set food-source-number 3
    set food one-of [1 2]
    set has-food? true
    set food-amount 8 + random 5
  ]
end

to setup-nests
  ; Marca os patches dos ninhos com cores específicas
  ask patches with [distancexy colony1-nest-x colony1-nest-y < 4] [
    set pcolor red + 2
  ]
  ask patches with [distancexy colony2-nest-x colony2-nest-y < 4] [
    set pcolor blue + 2
  ]
  ask patches with [distancexy colony3-nest-x colony3-nest-y < 4] [
    set pcolor green + 2
  ]
end

to setup-ants
  ; Colônia 1 - Vermelha
  create-ants1 20 [
    set shape "bug"
    set color red
    set size 2
    set health 100
    set strength 10 + random 5
    set role one-of ["worker" "explorer" "warrior"]
    set carrying false
    set pheromone-trail 0
    set home-colony 1
    setxy colony1-nest-x colony1-nest-y
    set target-x 0
    set target-y 0
  ]
  
  ; Colônia 2 - Azul
  create-ants2 20 [
    set shape "bug"
    set color blue
    set size 2
    set health 110
    set strength 12 + random 5
    set role one-of ["worker" "explorer" "warrior"]
    set carrying false
    set pheromone-trail 0
    set home-colony 2
    setxy colony2-nest-x colony2-nest-y
    set target-x 0
    set target-y 0
  ]
  
  ; Colônia 3 - Verde
  create-ants3 20 [
    set shape "bug"
    set color green
    set size 2
    set health 90
    set strength 8 + random 5
    set role one-of ["worker" "explorer" "warrior"]
    set carrying false
    set pheromone-trail 0
    set home-colony 3
    setxy colony3-nest-x colony3-nest-y
    set target-x 0
    set target-y 0
  ]
end

to setup-food
  ; Adiciona comida espalhada aleatoriamente
  ask n-of 25 patches with [not obstacle? and not nest? and food-source-number = 0] [
    set has-food? true
    set food-amount 3 + random 4
    set food 1
  ]
end

to setup-weather
  set current-weather "normal"
  set previous-weather "normal"
  set weather-timer 0
  apply-weather-visual-effects
end

; ========================================
; 3. PROCEDIMENTOS PRINCIPAIS (GO)
; ========================================

to go
  if not any? turtles with [breed != anteaters and breed != boas] [ 
    print "Todas as formigas morreram! Simulação encerrada."
    stop 
  ]
  
  ; Gerenciamento do ambiente
  manage-weather
  manage-toxic-zones
  maybe-spawn-predators
  
  ; Comportamento das formigas
  ask turtles with [breed != anteaters and breed != boas] [
    if who >= ticks [ stop ] ; atraso inicial
    
    ; Verificações de saúde e ambiente
    handle-environmental-effects
    
    if health > 0 [
      ; Comportamento baseado no papel
      if role = "warrior" [ warrior-behavior ]
      if role = "explorer" [ explorer-behavior ]
      if role = "worker" [ worker-behavior ]
      
      ; Movimento e navegação
      handle-movement
    ]
    
    ; Remove formigas mortas
    if health <= 0 [ die ]
  ]
  
  ; Comportamento dos predadores
  ask anteaters [ anteater-behavior ]
  ask boas [ boa-behavior ]
  
  ; Atualização do ambiente
  update-environment
  
  tick
end
; ========================================
; 4. COMPORTAMENTOS DAS FORMIGAS
; ========================================

to warrior-behavior
  ; Procura por inimigos próximos
  let enemies turtles in-radius 3 with [
    breed != [breed] of myself and 
    breed != anteaters and 
    breed != boas and
    home-colony != [home-colony] of myself
  ]
  
  if any? enemies [
    let target one-of enemies
    face target
    
    ; Combate
    if distance target <= 1 [
      if random strength > random [strength] of target [
        ask target [ 
          set health health - 20
          if health <= 0 [ die ]
        ]
      ]
    ]
    fd 0.5
    stop
  ]
  
  ; Patrulha próximo ao ninho
  let home-x colony1-nest-x
  let home-y colony1-nest-y
  if home-colony = 2 [ set home-x colony2-nest-x set home-y colony2-nest-y ]
  if home-colony = 3 [ set home-x colony3-nest-x set home-y colony3-nest-y ]
  
  if distancexy home-x home-y > 10 [
    facexy home-x home-y
  ]
  
  wiggle
end

to explorer-behavior
  ; Marca comida encontrada com feromônio
  if [has-food?] of patch-here and [food-amount] of patch-here > 0 [
    set pheromone-trail 100
    ask patch-here [ 
      set pheromone pheromone + 100
      set chemical chemical + 100
      set colony-scent [home-colony] of myself
    ]
  ]
  
  ; Exploração inteligente
  if not carrying [
    ; Procura por áreas não exploradas
    let unexplored-patches patches in-radius 5 with [
      pheromone < 10 and 
      not obstacle? and 
      not toxic?
    ]
    
    if any? unexplored-patches [
      let target-patch one-of unexplored-patches
      face target-patch
    ]
  ]
  
  wiggle
end

to worker-behavior
  if not carrying [
    ; Procura por comida
    if [has-food?] of patch-here and [food-amount] of patch-here > 0 [
      set carrying true
      set color orange + 1
      ask patch-here [ 
        set food-amount food-amount - 1
        if food-amount <= 0 [ 
          set has-food? false 
          set food 0
        ]
      ]
      rt 180
      stop
    ]
    
    ; Segue trilhas de feromônio da própria colônia
    let best-patch max-one-of neighbors4 with [
      (pheromone > 0 or chemical > 0.05) and 
      not obstacle? and 
      not toxic? and
      (colony-scent = 0 or colony-scent = [home-colony] of myself)
    ] [ pheromone + chemical ]
    
    if best-patch != nobody [
      face best-patch
    ]
  ]
  
  if carrying [
    ; Retorna ao ninho
    let home-x colony1-nest-x
    let home-y colony1-nest-y
    if home-colony = 2 [ set home-x colony2-nest-x set home-y colony2-nest-y ]
    if home-colony = 3 [ set home-x colony3-nest-x set home-y colony3-nest-y ]
    
    ; Verifica se chegou ao ninho
    if distancexy home-x home-y < 4 [
      set carrying false
      set color [color] of one-of turtles with [breed = [breed] of myself and not carrying]
      rt 180
      stop
    ]
    
    ; Deixa trilha de feromônio
    ask patch-here [ 
      set chemical chemical + 60
      set pheromone pheromone + 50
      set colony-scent [home-colony] of myself
    ]
    
    ; Navega em direção ao ninho
    uphill-nest-scent
  ]
end

; ========================================
; 5. COMPORTAMENTOS DOS PREDADORES
; ========================================

to anteater-behavior
  set hunt-timer hunt-timer + 1
  
  ; Caça formigas
  let prey turtles in-radius 2 with [
    breed != anteaters and breed != boas
  ]
  
  if any? prey [
    let target one-of prey
    face target
    if distance target <= 1 [
      ask target [ die ]
      set hunt-timer 0
    ]
  ]
  
  ; Movimento
  rt random 60
  lt random 60
  fd 0.7
  
  ; Remove predador após um tempo
  if hunt-timer > 200 [ die ]
end

to boa-behavior
  set hunt-timer hunt-timer + 1
  
  ; Caça tamanduás primeiro, depois formigas
  let anteater-prey anteaters in-radius 2
  if any? anteater-prey [
    let target one-of anteater-prey
    face target
    if distance target <= 1 [
      if random power > random [power] of target [
        ask target [ die ]
        set hunt-timer 0
      ]
    ]
  ]
  
  ; Se não há tamanduás, caça formigas
  if not any? anteater-prey [
    let ant-prey turtles in-radius 2 with [
      breed != anteaters and breed != boas
    ]
    if any? ant-prey [
      let target one-of ant-prey
      face target
      if distance target <= 1 [
        ask target [ die ]
        set hunt-timer 0
      ]
    ]
  ]
  
  ; Movimento mais lento
  rt random 45
  lt random 45
  fd 0.4
  
  ; Remove predador após um tempo
  if hunt-timer > 300 [ die ]
end

; ========================================
; 6. GERENCIAMENTO DO AMBIENTE
; ========================================

;; Procedimento para lidar com efeitos específicos do clima nas formigas
to handle-weather-effects
  ;; Efeitos da tempestade
  if current-weather = "tempestade"
  [
    ;; Tempestades podem desorientar as formigas
    if random 100 < 20 [  ;; 20% de chance por tick
      rt random 360  ;; Desorientação completa
    ]
    
    ;; Tempestades podem causar pequenos danos às formigas
    if random 100 < 5 [  ;; 5% de chance de dano
      set health health - 2
      if health <= 0 [ die ]
    ]
  ]
  
  ;; Efeitos da neve
  if current-weather = "neve"
  [
    ;; Neve pode reduzir a saúde devido ao frio
    if random-float 100 < 2 [  ;; 2% de chance por tick
      set health health - 1
      if health <= 0 [ die ]
    ]
  ]
  
  ;; Recuperação em clima normal
  if current-weather = "normal"
  [
    ;; Formigas podem recuperar saúde em clima normal
    if health < 100 and random 100 < 10 [  ;; 10% de chance de recuperação
      set health health + 1
    ]
  ]
end

;; Retorna a taxa de difusão baseada no clima atual
to-report get-weather-diffusion
  if current-weather = "normal" [ report diffusion-rate ]
  if current-weather = "chuvoso" [ report diffusion-rate * 0.5 ]  ;; Chuva diminui a difusão
  if current-weather = "seco" [ report diffusion-rate * 1.5 ]     ;; Clima seco aumenta a difusão
  if current-weather = "tempestade" [ report diffusion-rate * 0.2 ] ;; Tempestade reduz drasticamente a difusão
  if current-weather = "neve" [ report diffusion-rate * 0.3 ]     ;; Neve reduz significativamente a difusão
  report diffusion-rate  ;; Valor padrão caso algo dê errado
end

;; Retorna a taxa de evaporação baseada no clima atual
to-report get-weather-evaporation
  if current-weather = "normal" [ report evaporation-rate ]
  if current-weather = "chuvoso" [ report evaporation-rate * 1.5 ]  ;; Chuva aumenta a evaporação
  if current-weather = "seco" [ report evaporation-rate * 2 ]       ;; Clima seco aumenta ainda mais a evaporação
  if current-weather = "tempestade" [ report evaporation-rate * 2.5 ] ;; Tempestade causa evaporação muito rápida
  if current-weather = "neve" [ report evaporation-rate * 0.7 ]     ;; Neve preserva feromônios (menor evaporação)
  report evaporation-rate  ;; Valor padrão caso algo dê errado
end

;; Gerencia a mudança de clima com o tempo
to manage-weather
  set weather-timer weather-timer + 1
  
  ;; Muda o clima a cada 100 ticks
  if weather-timer >= 100
  [
    set weather-timer 0
    ;; Armazena o clima anterior
    set previous-weather current-weather
    ;; Escolhe um novo clima aleatório
    set current-weather one-of ["normal" "chuvoso" "seco" "tempestade" "neve"]
    
    ;; Só mostra a mensagem se o clima mudou
    if current-weather != previous-weather [
    if current-weather = "chuvoso" [ print "O clima ficou chuvoso!" ]
    if current-weather = "seco" [ print "O clima ficou seco!" ]
    if current-weather = "normal" [ print "O clima voltou ao normal." ]
    if current-weather = "tempestade" [ print "Uma tempestade está chegando!" ]
    if current-weather = "neve" [ print "Começou a nevar!" ]
    ]
    ;; Aplica efeitos visuais e comportamentais do novo clima
    apply-weather-visual-effects
    
    ;; Efeitos especiais para tempestade e neve
    if current-weather = "tempestade" [
      ;; Tempestades podem destruir algumas trilhas de feromônios
      ask patches with [chemical > 0 and not nest? and not any? turtles-here] [
        if random 100 < 30 [  ;; 30% de chance de destruir feromônios
          set chemical 0
        ]
      ]
    ]
    
    if current-weather = "neve" [
      ;; Neve pode reduzir a velocidade das formigas
      ask turtles [
        if random 100 < 50 [  ;; 50% das formigas são afetadas
          set size 1.8  ;; Formigas menores para representar movimento mais lento
        ]
      ]
    ]
    
    if current-weather != "neve" [
      ;; Restaura o tamanho normal das formigas quando não está nevando
      ask turtles [ set size 2 ]
    ]
  ]
end

;; Gerencia o aparecimento e desaparecimento de zonas tóxicas
to manage-toxic-zones
  ;; Atualiza os timers das zonas tóxicas existentes
  ask patches with [toxic?]
  [
    set toxic-timer toxic-timer + 1
    if toxic-timer > 50  ;; Zonas tóxicas duram 50 ticks
    [
      set toxic? false
      set toxic-timer 0
    ]
  ]
  
  ;; Cria novas zonas tóxicas aleatoriamente
  if random 100 < 1  ;; 1% de chance por tick
  [
    ask one-of patches with [not nest? and not obstacle? and food = 0 and not toxic?]
    [
      set toxic? true
      set toxic-timer 0
      
      ;; Cria uma zona tóxica em forma de círculo
      ask patches in-radius 3
      [
        if not nest? and not obstacle? and food = 0
        [
          set toxic? true
          set toxic-timer 0
        ]
      ]
    ]
  ]
end

to return-to-nest  ;; procedimento de tartaruga
  ifelse nest?
  [ ;; solta comida e sai novamente
    set color red
    rt 180 ]
  [ set chemical chemical + 60  ;; solta um pouco de feromônio
    uphill-nest-scent ]         ;; segue em direção ao maior valor de nest-scent
end

to look-for-food  ;; procedimento de tartaruga
  if food > 0
  [ set color orange + 1     ;; pega comida
    set food food - 1        ;; e reduz a fonte de comida
    rt 180                   ;; e vira-se
    stop ]
  ;; vai na direção onde o cheiro químico é mais forte
  if (chemical >= 0.05) and (chemical < 2)
  [ uphill-chemical ]
end

;; fareja à esquerda e à direita, e vai onde o cheiro é mais forte
to uphill-chemical  ;; procedimento de tartaruga
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

;; fareja à esquerda e à direita, e vai onde o cheiro é mais forte
to uphill-nest-scent  ;; procedimento de tartaruga
  let scent-ahead nest-scent-at-angle   0
  let scent-right nest-scent-at-angle  45
  let scent-left  nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

; ========================================
; 7. FUNÇÕES AUXILIARES
; ========================================

to wiggle  ;; procedimento de tartaruga
  rt random 40
  lt random 40
  
  ;; Verifica se há obstáculo à frente, se sim, vira-se
  if not can-move? 1 or [obstacle?] of patch-ahead 1
  [ rt 180 ]
end

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent] of p
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end

; ========================================
; 8. INFORMAÇÕES DE COPYRIGHT
; ========================================

; Modelo baseado no trabalho original de Uri Wilensky (1997)
; com extensões significativas para múltiplas colônias,
; predadores, papéis especializados e sistema climático avançado.
; 
; Funcionalidades integradas:
; - Três colônias de formigas com características únicas
; - Sistema de papéis (trabalhadora, exploradora, guerreira)
; - Predadores em dois níveis (tamanduás e cobras)
; - Sistema climático com 5 tipos de clima
; - Zonas tóxicas dinâmicas
; - Obstáculos e navegação inteligente
; - Combate entre colônias
; - Múltiplos tipos de feromônios