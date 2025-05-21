; Modelo de Formigas com Predadores, Raças e Papéis Inteligentes - NetLogo

; 1. Variáveis Globais e Raças
; ----------------------------------
globals [current-weather weather-timer]

breeds [ants1 ant1 ants2 ant2 ants3 ant3]
breeds [anteaters anteater boas boa] ; predadores nível 1 e 2

; Variáveis de cada raça de formiga
ants1-own [health strength role carrying pheromone-trail]
ants2-own [health strength role carrying pheromone-trail]
ants3-own [health strength role carrying pheromone-trail]

; Predadores
anteaters-own [power]
boas-own [power]

patches-own [has-food? food-amount pheromone obstacle?]


; 2. Setup Inicial
; ----------------------------------
to setup
  clear-all
  set current-weather "normal"
  set weather-timer 100
  setup-patches
  setup-nests
  setup-ants
  setup-food
  reset-ticks
end


; 3. Patches do Ambiente
; ----------------------------------
to setup-patches
  ask patches [
    set pcolor green
    set pheromone 0
    set obstacle? false
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
    set carrying false
    set pheromone-trail 0
    setxy -10 -10
  ]
  create-ants2 20 [
    set shape "ant"
    set color blue
    set size 1.5
    set health 110
    set strength 12
    set role one-of ["worker" "explorer" "warrior"]
    set carrying false
    set pheromone-trail 0
    setxy 10 -10
  ]
  create-ants3 20 [
    set shape "ant"
    set color green
    set size 1.5
    set health 90
    set strength 8
    set role one-of ["worker" "explorer" "warrior"]
    set carrying false
    set pheromone-trail 0
    setxy 0 10
  ]
end


; 6. Colocação de Comida
; ----------------------------------
to setup-food
  ask n-of 30 patches with [not obstacle?] [
    set has-food? true
    set food-amount 5 + random 5
    set pcolor blue
  ]
end


; 7. Loop Principal
; ----------------------------------
to go
  change-weather
  maybe-spawn-predators
  diffuse pheromone 0.25
  ask patches [ set pheromone pheromone * 0.95 ]
  ask turtles [
    if health > 0 [
      if role = "warrior" [warrior-behavior]
      if role = "explorer" [explorer-behavior]
      if role = "worker" [worker-behavior]
    ]
    if health <= 0 [die]
  ]
  ask anteaters [hunt-ants]
  ask boas [hunt-anteaters]
  tick
end


; 8. Comportamento de Formigas Guerreiras
; ----------------------------------
to warrior-behavior
  let enemy one-of turtles in-radius 2 with [breed != breed-of myself and breed != boas and breed != anteaters]
  if enemy != nobody [
    if random strength > random [strength] of enemy [ ask enemy [ die ] ]
    stop
  ]
  if distancexy 0 0 < 15 [rt random 90 lt random 90 fd 0.5]
end


; 9. Exploradoras - Detectam Comida e Marcam com Feromônio
; ----------------------------------
to explorer-behavior
  if [has-food?] of patch-here [
    set pheromone-trail 100
    set [pheromone] of patch-here pheromone-trail
  ]
  wiggle
end


; 10. Trabalhadoras - Seguem Feromônio e Carregam Comida
; ----------------------------------
to worker-behavior
  if not carrying [
    let strongest-patch max-one-of neighbors4 with [pheromone > 0 and not obstacle?] [pheromone]
    if strongest-patch != nobody [ face strongest-patch ]
    fd 1
    if [has-food?] of patch-here [
      set carrying true
      set [food-amount] of patch-here ([food-amount] of patch-here - 1)
      if [food-amount] of patch-here <= 0 [ set has-food? false set pcolor green ]
    ]
  ]
  if carrying [
    rt random 20 lt random 20 fd 1
    set pheromone-trail pheromone-trail + 50
    ask patch-here [ set pheromone pheromone + 50 ]
    if patch-here = patch -10 -10 or patch-here = patch 10 -10 or patch-here = patch 0 10 [
      set carrying false
    ]
  ]
end


; 11. Predadores - Aparecimento
; ----------------------------------
to maybe-spawn-predators
  if random-float 1000 < 1 [
    create-anteaters 1 [
      set shape "wolf"
      set color orange
      set size 2
      set power 40
      setxy random-xcor random-ycor
    ]
  ]
  if random-float 2000 < 0.5 [
    create-boas 1 [
      set shape "snake"
      set color brown
      set size 2.5
      set power 70
      setxy random-xcor random-ycor
    ]
  ]
end


; 12. Predadores - Ações
; ----------------------------------
to hunt-ants
  let prey one-of turtles in-radius 2 with [breed != breed-of myself and breed != boas and breed != anteaters]
  if prey != nobody [
    ask prey [ die ]
  ]
  rt random 90
  lt random 90
  fd 0.7
end

to hunt-anteaters
  let prey one-of anteaters in-radius 2
  if prey != nobody [
    if random power > random [power] of prey [ ask prey [ die ] ]
  ]
  rt random 90
  lt random 90
  fd 0.4
end


; 13. Clima
; ----------------------------------
to change-weather
  set weather-timer weather-timer - 1
  if weather-timer <= 0 [
    set current-weather one-of ["normal" "rainy" "dry"]
    set weather-timer 100
  ]
  if current-weather = "rainy" [set diffusion-rate 0.5 set evaporation-rate 1.5]
  if current-weather = "dry" [set diffusion-rate 1.5 set evaporation-rate 2.0]
end

