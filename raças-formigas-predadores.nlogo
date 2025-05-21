; Formigas com Predadores, Raças e Papéis Inteligentes incluindo guerreiras 

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


; 3. Patches do Ambiente
; ----------------------------------
to setup-patches
  ask patches [
    set pcolor green
    if random 100 < 10 [set pcolor brown set obstacle? true]
  ]
end


; 4. Criação dos Ninhos
; ----------------------------------
to setup-nests
  ask patch -10 -10 [set pcolor violet]
  ask patch 10 -10 [set pcolor cyan]
  ask patch 0 10 [set pcolor lime]
end


; 5. Criação das Formigas
; ----------------------------------
to setup-ants
  create-ants1 20 [
    set shape "ant"
    set color red
    set size 1.5
    set health 100
    set strength 10
    set role one-of ["worker" "explorer" "warrior"]
    setxy -10 -10
  ]
  create-ants2 20 [
    set shape "ant"
    set color blue
    set size 1.5
    set health 110
    set strength 12
    set role one-of ["worker" "explorer" "warrior"]
    setxy 10 -10
  ]
  create-ants3 20 [
    set shape "ant"
    set color green
    set size 1.5
    set health 90
    set strength 8
    set role one-of ["worker" "explorer" "warrior"]
    setxy 0 10
  ]
end

; 6. Loop Principal
; ----------------------------------
to go
  change-weather
  maybe-spawn-predators
  ask turtles [
    if health > 0 [
      if role = "warrior" [warrior-behavior]
      if role != "warrior" [move-ant]
    ]
    if health <= 0 [die]
  ]
  ask anteaters [hunt-ants]
  ask boas [hunt-anteaters]
  tick
end


; 7. Movimento das Formigas (não guerreiras)
; ----------------------------------
to move-ant
  if not can-move? 1 or [pcolor] of patch-ahead 1 = brown [ rt 180 ]
  if [pcolor] of patch-here = yellow [ set health health - 1 ]
  fd 1
end


; 8. Comportamento de Formigas Guerreiras
; ----------------------------------
to warrior-behavior
  let enemy one-of turtles in-radius 2 with [breed != breed-of myself and breed != boas and breed != anteaters]
  if enemy != nobody [
    if random strength > random [strength] of enemy [ ask enemy [ die ] ]
    stop
  ]
  if distancexy 0 0 < 15 [rt random 90 lt random 90 fd 0.5] ; patrulha
end
