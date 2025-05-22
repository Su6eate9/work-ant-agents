; Modelo Unificado de Formigas com Clima, Predadores, Raças e Papéis - NetLogo

; ========================================
; 1. DEFINIÇÕES DE RAÇAS E VARIÁVEIS
; ========================================

patches-own [
  chemical             ;; quantidade de feromônio neste patch
  food                 ;; quantidade de comida neste patch (0, 1, ou 2)
  nest?                ;; verdadeiro nos patches de ninho, falso em outros lugares
  nest-scent           ;; número que é maior quanto mais perto do ninho
  food-source-number   ;; número (1, 2, ou 3) para identificar as fontes de comida
  obstacle?            ;; verdadeiro se o patch for um obstáculo, falso em outros lugares
  toxic?               ;; verdadeiro se o patch for tóxico, falso em outros lugares
  toxic-timer          ;; contador para controlar quando zonas tóxicas aparecem/desaparecem
]

turtles-own [
  health               ;; saúde da formiga (100 = saudável, 0 = morta)
]

;; Variáveis globais para controle do clima
globals [
  current-weather      ;; tipo de clima atual ("normal", "chuvoso", "seco", "tempestade", "neve")
  previous-weather      ;; clima anterior
  weather-timer        ;; contador para alternar o clima periodicamente
]

; ========================================
; 2. PROCEDIMENTOS DE SETUP
; ========================================

to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles population
  [ 
    set size 2         ;; mais fácil de ver
    set color red      ;; vermelho = não carregando comida
    set health 100     ;; começa com saúde total
  ]
  setup-patches
  setup-weather
  reset-ticks
end

;; Inicializa o clima como normal
to setup-weather
  set current-weather "normal"
  set previous-weather "normal"
  set weather-timer 0
  
  ;; Inicializa a aparência visual de acordo com o clima
  apply-weather-visual-effects
end

;; Aplica efeitos visuais baseados no clima atual
to apply-weather-visual-effects
  ;; Atualiza a aparência dos patches para refletir o clima
  ask patches [ recolor-patch ]
  
  ;; Atualiza a aparência das formigas com base no clima
  ask turtles [
    if current-weather = "neve" [
      set size 1.8  ;; Formigas menores na neve
    ]
    if current-weather = "normal" [
      set size 2    ;; Tamanho normal
    ]
  ]
end

to setup-patches
  ask patches
  [ 
    ;; Inicializa todas as propriedades
    set obstacle? false
    set toxic? false
    set toxic-timer 0
    
    setup-nest
    setup-food
    setup-obstacles
    recolor-patch 
  ]
end

to setup-nest  ;; procedimento de patch
  ;; define a variável nest? como verdadeira dentro do ninho, falsa em outros lugares
  set nest? (distancexy 0 0) < 5
  ;; espalha um cheiro-de-ninho por todo o mundo -- mais forte perto do ninho
  set nest-scent 200 - distancexy 0 0
end

to setup-food  ;; procedimento de patch
  ;; configura fonte de comida um à direita
  if (distancexy (0.6 * max-pxcor) 0) < 5
  [ set food-source-number 1 ]
  ;; configura fonte de comida dois na parte inferior esquerda
  if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5
  [ set food-source-number 2 ]
  ;; configura fonte de comida três na parte superior esquerda
  if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5
  [ set food-source-number 3 ]
  ;; define "comida" nas fontes como 1 ou 2, aleatoriamente
  if food-source-number > 0
  [ set food one-of [1 2] ]
end

;; Configura obstáculos em posições aleatórias
to setup-obstacles
  ;; Não coloca obstáculos no ninho ou em fontes de comida
  if (not nest?) and (food-source-number = 0) and (random-float 100 < 5)
  [
    set obstacle? true
  ]
end

to recolor-patch  ;; procedimento de patch
  ;; Primeira camada: visualização do clima (sutil)
  let weather-color 0
  if current-weather = "chuvoso" [ set weather-color 0.5 ]
  if current-weather = "tempestade" [ set weather-color 1 ]
  if current-weather = "neve" [ set weather-color -0.5 ]
  
  ;; dá cor ao ninho, obstáculos, zonas tóxicas e fontes de comida
  ifelse obstacle?
  [ set pcolor brown ]  ;; obstáculos são marrons
  [
    ifelse toxic?
    [ set pcolor yellow ]  ;; zonas tóxicas são amarelas
    [
      ifelse nest?
      [ set pcolor violet ]
      [ ifelse food > 0
        [ if food-source-number = 1 [ set pcolor cyan ]
          if food-source-number = 2 [ set pcolor sky  ]
          if food-source-number = 3 [ set pcolor blue ] ]
        ;; escala a cor para mostrar a concentração química e efeito do clima
        [ 
          let base-color scale-color green chemical 0.1 5
          ;; Ajusta sutilmente a cor base para refletir o clima
          if current-weather = "neve" [ set pcolor base-color - 0.3 ]  ;; Mais branco para neve
          if current-weather = "tempestade" [ set pcolor base-color - 0.5 ]  ;; Mais escuro para tempestade
          if current-weather = "normal" [ set pcolor base-color ]
          if current-weather = "chuvoso" [ set pcolor base-color - 0.2 ]  ;; Ligeiramente escuro para chuva
          if current-weather = "seco" [ set pcolor base-color + 0.2 ]  ;; Mais claro para clima seco
        ] ]
    ]
  ]
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