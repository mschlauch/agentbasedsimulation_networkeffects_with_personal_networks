
undirected-link-breed [connections connection]

turtles-own [node-id
  basic_purchase_willingness ;basilare Kaufbereitschaft
  network_effect_BLUE
  network_effect_RED
  network_effect_GREEN
  residual_purchase_willingness_RED;
  residual_purchase_willingness_BLUE
  residual_purchase_willingness_GREEN
  num-red-vecinos
  num-green-vecinos
  num-blue-vecinos
  consumerrent_increment
  ]

connections-own [strength]

globals [
  links-list ;liste aller Verbindungen
  consumer_rent ;Konsumentenrente
  producer_rent ;Produzentenrente
  balance_RED ;Guthaben von Rot
  balance_GREEN ;Guthaben von Grün
  balance_BLUE ;Guthaben von Blau
  sold_RED ;
  sold_GREEN ;
  sold_BLUE ; wieviele wurden in dieser Runde wieder vermietet/verkauft von der Firma Blau
  profit_RED
  profit_GREEN
  profit_BLUE
  
  
  
  
  
  ]

to setup
  
  
  import-network
  set balance_RED initial_capital_RED
  set balance_GREEN initial_capital_GREEN
  set balance_BLUE initial_capital_BLUE
  

  
  reset-ticks
end

to go
  set sold_GREEN 0
  set sold_RED 0
  set sold_BLUE 0
  
  set consumer_rent 0
  set producer_rent 0
  consumer_choose
  producer_sell
  
    
  
  tick
end

to consumer_choose
  

  
    
  
  ask turtles [
    ;im Netz durchgehen und Kaufbereitschaft berechnen...network_effect_RED...
  
     set num-red-vecinos 0
   set num-green-vecinos 0
   set num-blue-vecinos 0
  
   set num-red-vecinos count (connection-neighbors with [color = red])
   set num-green-vecinos count (connection-neighbors with [color = green])
   set num-blue-vecinos count (connection-neighbors with [color = blue])
   
   
  ; set num-red-vecinos (link-neighbors with [color = red])
  ;  set num-green-vecinos count (link-neighbors with [color = green])
 ;   set num-blue-vecinos count (link-neighbors with [color = blue])
; ask my-links with [color = red][]
 ;ask link-neighbors with [color = red][]

    if compatibility_RED_GREEN = TRUE AND compatibility_RED_BLUE = FALSE AND compatibility_BLUE_GREEN = FALSE
    [set num-red-vecinos (num-red-vecinos + num-green-vecinos)
     set num-green-vecinos (num-red-vecinos)   
        ]
    if compatibility_RED_BLUE = TRUE AND compatibility_RED_GREEN = FALSE AND compatibility_BLUE_GREEN = FALSE
     [set num-red-vecinos (num-red-vecinos + num-blue-vecinos)
     set num-blue-vecinos (num-red-vecinos)  
       ]
     if compatibility_BLUE_GREEN = TRUE AND compatibility_RED_GREEN = FALSE AND compatibility_RED_BLUE = FALSE
     [set num-blue-vecinos (num-blue-vecinos + num-green-vecinos)
     set num-green-vecinos (num-blue-vecinos)   
      ]
     
    if compatibility_RED_GREEN = TRUE AND compatibility_RED_BLUE = TRUE 
    [set num-red-vecinos (num-red-vecinos + num-green-vecinos + num-blue-vecinos)
      
      set num-blue-vecinos (num-red-vecinos)  
     set num-green-vecinos (num-red-vecinos)   
        ]
    if compatibility_RED_BLUE = TRUE AND compatibility_RED_GREEN = TRUE
     [set num-red-vecinos (num-red-vecinos + num-green-vecinos + num-blue-vecinos)
      
      set num-blue-vecinos (num-red-vecinos)  
     set num-green-vecinos (num-red-vecinos)    
       ]
    
     ;Netzwerkeffekte werden ausgerechnet
 
    set network_effect_RED  (num-red-vecinos * network_externality_per_connection)
    set network_effect_GREEN (num-green-vecinos * network_externality_per_connection)
    set network_effect_BLUE  (num-blue-vecinos * network_externality_per_connection)
    
   ;damit das Spiel etwas weniger deterministisch wirkt (Modellierung nicht-absolute Information), schwanken die purchase-willingness (kognitive dissonanz)
    let k1 (random random_preference_noise) * basic_purchase_willingness
    let k2 (random random_preference_noise) * basic_purchase_willingness
    let k3 (random random_preference_noise) * basic_purchase_willingness
    
    set residual_purchase_willingness_RED (basic_purchase_willingness + network_effect_RED - price_RED) + k1
    set residual_purchase_willingness_BLUE (basic_purchase_willingness + network_effect_BLUE - price_BLUE) + k2
    set residual_purchase_willingness_GREEN (basic_purchase_willingness + network_effect_GREEN - price_GREEN) + k3
    
   
    if balance_BLUE < 0 [set residual_purchase_willingness_BLUE 0]
    if balance_RED < 0 [set residual_purchase_willingness_RED 0]
    if balance_GREEN < 0 [set residual_purchase_willingness_GREEN 0]
    ;ist eine Firma pleite, steht ihr Produkt nicht mehr zur Verfügung
    
    if residual_purchase_willingness_RED > residual_purchase_willingness_BLUE [
      if residual_purchase_willingness_RED > residual_purchase_willingness_GREEN [
      ;ROT hat gewonnen
       ifelse balance_RED < 0 [
      set consumerrent_increment 0
      set color gray]
      [
      set color red
      set consumerrent_increment (basic_purchase_willingness + network_effect_RED - price_RED) ;die tatsächliche Konsumentenrente kommt aus den echten Preferenzen her (Entschediungen werden durch unvollst. Information verzerrt)
      set sold_RED (sold_RED + 1)
        ]
      ]
    ]
     
     if residual_purchase_willingness_GREEN > residual_purchase_willingness_BLUE [
      if residual_purchase_willingness_GREEN > residual_purchase_willingness_RED [
      ;Grün hat gewonnen
      ifelse balance_GREEN < 0 [
      set consumerrent_increment 0
      set color gray][
      set color green
      set consumerrent_increment (basic_purchase_willingness + network_effect_GREEN - price_GREEN) ;die tatsächliche Konsumentenrente kommt aus den echten Preferenzen her (Entschediungen werden durch unvollst. Information verzerrt)
      set sold_GREEN (sold_GREEN + 1)
        ]
      ]
    ]

     if residual_purchase_willingness_BLUE > residual_purchase_willingness_GREEN [
      if residual_purchase_willingness_BLUE > residual_purchase_willingness_RED [
      ;Grün hat gewonnen
      ifelse balance_BLUE < 0 [ ;ist die Firma pleite, wird nix mehr gekauft...
      set consumerrent_increment 0
      set color gray]
      [
      set color blue
      set consumerrent_increment (basic_purchase_willingness + network_effect_BLUE - price_BLUE) ;die tatsächliche Konsumentenrente kommt aus den echten Preferenzen her (Entschediungen werden durch unvollst. Information verzerrt)
      set sold_BLUE (sold_BLUE + 1)
        ]
      ]
    ]
    
     if residual_purchase_willingness_RED <= 0 AND residual_purchase_willingness_BLUE <= 0 AND residual_purchase_willingness_GREEN <= 0
    [ ;sind alle Firmen pleite, wird nix mehr gekauft...
      set consumerrent_increment 0
      set color gray]
   
     set consumer_rent (consumer_rent + consumerrent_increment)
   
  ]
end

to producer_sell
  set profit_RED (sold_RED * (price_RED - marginal_costs_RED) - fixed_costs_RED)
  set profit_BLUE (sold_BLUE * (price_BLUE - marginal_costs_BLUE) - fixed_costs_BLUE)
  set profit_GREEN (sold_GREEN * (price_GREEN - marginal_costs_GREEN) - fixed_costs_GREEN)
  set producer_rent (profit_RED + profit_BLUE + profit_GREEN)
  ifelse balance_RED > 0 [
  set balance_RED (balance_RED + profit_RED)]
  [
  ask turtles with [color = red] [set color gray]];bei Marktaustritt kaufen die Leute auch das Produkt nicht mehr
  
  ifelse balance_GREEN > 0 [
  set balance_GREEN (balance_GREEN + profit_GREEN)]
  [
  ask turtles with [color = green] [set color gray]]
  
   ifelse balance_BLUE > 0 [
  set balance_BLUE (balance_BLUE + profit_BLUE)]
   [
  ask turtles with [color = blue] [set color gray]]

  
end

;INITIALISATION following

to import-network
  clear-all
  set-default-shape turtles "circle"
  import-attributes
  layout-circle (sort turtles) (max-pxcor - 1)
 ; layout-radial turtles connections (turtle 1)
  import-links
end

;; This procedure reads in a files that contains node-specific attributes
;; including an unique identification number
to import-attributes
  ;; This opens the file, so we can use it.
  file-open file_consumer_properties
  ;; Read in all the data in the file
  ;; data on the line is in this order:
  ;; node-id attribute1 attribute2
  while [not file-at-end?]
  [
    ;; this reads a single line into a three-item list
    let items read-from-string (word "[" file-read-line "]")
    crt 1 [
      set node-id item 0 items
      set size    item 1 items
      set color   item 2 items
      set basic_purchase_willingness   item 3 items
    ]
  ]
  file-close
end

;; This procedure reads in a file that contains all the links
;; The file is simply 3 columns separated by spaces.  In this
;; example, the links are directed.  The first column contains
;; the node-id of the node originating the link.  The second
;; column the node-id of the node on the other end of the link.
;; The third column is the strength of the link.

to import-links
  ;; This opens the file, so we can use it.
  file-open file_network_properties
  ;; Read in all the data in the file
  while [not file-at-end?]
  [
    ;; this reads a single line into a three-item list
    let items read-from-string (word "[" file-read-line "]")
    ask get-node (item 0 items)
    [
      
      create-connection-with get-node (item 1 items)
      
     ; create-connection-with get-node (item 1 items)
      ;  [ set label item 2 items ]
    ]
  ]
  file-close
end

;; Helper procedure for looking up a node by node-id.
to-report get-node [id]
  report one-of turtles with [node-id = id]
end

;TODO: basic Nachfragekurvenverteilung
;
; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
612
36
1056
501
17
17
12.4
1
12
1
1
1
0
0
0
1
-17
17
-17
17
1
1
1
ticks
30.0

BUTTON
3
10
139
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1056
37
1311
194
Consumer surplus
t
Rente
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot consumer_rent"

PLOT
1055
193
1311
356
Producer surplus
t
Profit
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot producer_rent"
"pen-1" 1.0 0 -2674135 true "" "plot profit_RED"
"pen-2" 1.0 0 -13345367 true "" "plot profit_BLUE"
"pen-3" 1.0 0 -10899396 true "" "plot profit_GREEN"

PLOT
1056
355
1311
505
Total welfare
t
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (consumer_rent + producer_rent)"

OUTPUT
1310
37
1485
241
12

SLIDER
179
328
358
361
fixed_costs_BLUE
fixed_costs_BLUE
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
179
362
358
395
marginal_costs_BLUE
marginal_costs_BLUE
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
181
397
359
430
price_BLUE
price_BLUE
0
100
100
1
1
NIL
HORIZONTAL

INPUTBOX
181
432
358
492
initial_capital_BLUE
46000
1
0
Number

INPUTBOX
5
431
178
491
initial_capital_RED
455
1
0
Number

SLIDER
5
328
177
361
fixed_costs_RED
fixed_costs_RED
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
5
362
176
395
marginal_costs_RED
marginal_costs_RED
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
5
396
177
429
price_RED
price_RED
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
371
331
563
364
fixed_costs_GREEN
fixed_costs_GREEN
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
371
365
562
398
marginal_costs_GREEN
marginal_costs_GREEN
0
100
19
1
1
NIL
HORIZONTAL

SLIDER
371
399
562
432
price_GREEN
price_GREEN
0
100
100
1
1
NIL
HORIZONTAL

INPUTBOX
372
432
562
492
initial_capital_GREEN
455
1
0
Number

INPUTBOX
1
44
246
104
file_consumer_properties
attributes_world4groups.txt
1
0
String

INPUTBOX
247
44
492
104
file_network_properties
links_world4groups.txt
1
0
String

SLIDER
2
107
317
140
network_externality_per_connection
network_externality_per_connection
0
100
73
1
1
NIL
HORIZONTAL

SWITCH
4
224
242
257
compatibility_RED_GREEN
compatibility_RED_GREEN
0
1
-1000

SWITCH
3
259
238
292
compatibility_RED_BLUE
compatibility_RED_BLUE
0
1
-1000

SWITCH
4
293
248
326
compatibility_BLUE_GREEN
compatibility_BLUE_GREEN
0
1
-1000

BUTTON
145
10
208
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1347
247
1447
292
NIL
sold_GREEN
17
1
11

MONITOR
1346
295
1427
340
NIL
sold_BLUE
17
1
11

MONITOR
1345
342
1418
387
NIL
sold_RED
17
1
11

MONITOR
1457
343
1553
388
NIL
balance_RED
17
1
11

MONITOR
1454
245
1568
290
NIL
balance_GREEN
17
1
11

MONITOR
1456
295
1560
340
NIL
balance_BLUE
17
1
11

PLOT
368
143
560
318
demand curve
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"clear-plot\nlet sorted_turtles sort-on [(- basic_purchase_willingness)] turtles\n; let sorted_turtles sort-by [ ([basic_purchase_willingness] of ?1) < ([basic_purchase_willingness]  of ?2) ] turtles \n;  let list-2 [basic_purchase_willingness] of sorted_turtles\n  let list-1  map [ [basic_purchase_willingness] of ? ] sorted_turtles\n ; let list-2 [node-id] of turtles\n ;set turtlenumber count turtles\n  let list-2 n-values count turtles [ ? ]\n  \n  (foreach list-2 list-1 [plotxy ?1 ?2])" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
332
107
586
140
random_preference_noise
random_preference_noise
0
5
1.1
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The code example provides an illustration of how to import network data from external files.  This is useful when you have a specific network, perhaps created in another program or taken from real world data, that you would like to recreate in NetLogo.

It imports data from two different files.  The first is the "attributes.txt" file, which contains information about the nodes -- in this case, the node-id, size, and color of each node. The second is the "links.txt" file, which contains information on how the nodes are connected and the strength of their connection.

## NETLOGO FEATURES

The link primitives are used to represent and process connections between nodes.

The file primitives are used to read data from external files.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line-half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
import-network
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
