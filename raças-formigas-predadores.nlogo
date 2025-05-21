; Tipos de Formigas com Predadores

; 1. Variáveis Globais e Raças
; ----------------------------------
globals [current-weather weather-timer]

breeds [ants1 ant1 ants2 ant2 ants3 ant3]
breeds [anteaters anteater boas boa] ; predadores nível 1 e 2

; Variáveis de cada raça de formiga
ants1-own [health strength role]
ants2-own [health strength role]
ants3-own [health strength role]

; Predadores
anteaters-own [power]
boas-own [power]


; 2. Setup Inicial
; ----------------------------------
to setup
  clear-all
  set current-weather "normal"
  set weather-timer 100
  setup-patches
  setup-nests
  setup-ants
  reset-ticks
end
