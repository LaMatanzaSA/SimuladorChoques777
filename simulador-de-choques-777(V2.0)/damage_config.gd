class_name DamageConfig
extends Resource
## Parámetros de balance del sistema de daño.

## Umbral de destrucción total.
@export var dano_maximo: float = 100.0
## Velocidad que se considera un choque "a fondo".
@export var fuerza_referencia: float = 400.0
## Daño de un choque muy suave y de un choque a máxima velocidad.
@export var dano_minimo_por_golpe: float = 10.0
@export var dano_maximo_por_golpe: float = 40.0
