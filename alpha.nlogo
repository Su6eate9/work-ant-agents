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
