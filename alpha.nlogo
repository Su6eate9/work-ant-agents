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
  energy               ;; energia da formiga (100 = cheia, 0 = exausta)
  carrying-food?       ;; verdadeiro se a formiga está carregando comida, falso se não
  carrying-chemical?   ;; verdadeiro se a formiga está carregando feromônio, falso se não

]

;; Variáveis globais para controle do clima
globals [
  current-weather            ;; tipo de clima atual ("normal", "chuvoso", "seco", "tempestade", "neve")
  weather-timer              ;; contador para alternar o clima periodicamente
  weather-duration           ;; duração do clima atual em ticks
  weather-duration-timer     ;; contador para controlar a duração do clima
  weather-duration-remaining ;; tempo restante para o clima atual
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles population [
    set size 2                     ;; mais fácil de ver
    set color red                  ;; vermelho = não carregando comida
    set health 100                 ;; saúde inicial
    set energy 100                 ;; energia inicial
    set carrying-food? false       ;; não carregando comida
    set carrying-chemical? false   ;; não carregando feromônio
  ]
  setup-patches
  setup-weather
  reset-ticks
end

;; Inicializa o clima como normal e define o tempo de duração
to setup-weather
  set current-weather "normal"
  set weather-timer 0
  set weather-duration 100 + random 100 ;; duração aleatória entre 100 e 200 ticks
  set weather-duration-timer weather-duration

  ;; Inicializa a aparência visual de acordo com o clima
  apply-weather-visuals-effects
end

;; Aplica os efeitos visuais do clima atual
to apply-weather-visuals-effects
  ;; Atualiza a aparência dos patches de acordo com o clima
  ask patches [ recolor-patch ]

  ;; Atualiza a aparência das formigas de acordo com o clima
  ask patches [
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
  ask patches [
    ;; Inicializa os patches com valores padrão
    set chemical 0
    set food 0
    set nest? false
    set nest-scent 0
    set food-source-number 0
    set obstacle? false
    set toxic? false
    set toxic-timer 0

    setup-nest
    setup-food
    setup-obstacles
    setup-toxicity
    recolor-patch
  ]

  ;; Cria o ninho no centro do mundo
  ask patch 0 0 [
    set nest? true
    set food 2 ;; O ninho tem comida (2 unidades)
    set chemical 100 ;; O ninho tem feromônio (100 unidades)
    set nest-scent 100 ;; O ninho tem o maior cheiro de ninho (100)
  ]

  ;; Cria fontes de comida e obstáculos aleatórios
  create-food-sources-and-obstacles
end

to setup-nest  ;; Define o patch como ninho se estiver no centro do mundo
  ;; define a variável nest? como verdadeira dentro do ninho, falsa em outros lugares
  set nest? (distancexy 0 0) < 5
  ;; espalha um cheiro-de-ninho por todo o mundo -- mais forte perto do ninho
  set nest-scent 200 - distancexy 0 0
end

to setup-food  ;; Procedimento de patch
  ;; Configura fonte de comida um à direita
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
  ;; define obstáculos em posições aleatórias
  if random-float 1 < obstacle-density [
    set obstacle? true
    set food 0          ;; Os obstáculos não têm comida
    set chemical 0      ;; Os obstáculos não têm feromônio
    set nest-scent 0    ;; Os obstáculos não têm cheiro de ninho
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