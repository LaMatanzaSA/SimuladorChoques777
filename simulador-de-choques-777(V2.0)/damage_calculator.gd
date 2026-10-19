class_name DamageCalculator
extends Node

## Se emite cada vez que cambia el daño acumulado.
signal dano_actualizado(dano_actual: float, dano_maximo: float)

## Umbral de destrucción total.
@export var dano_maximo : float = 100.0
## Velocidad que se considera un choque "a fondo".
@export var fuerza_referencia : float = 400.0
## Daño de un choque muy suave y de un choque a máxima velocidad.
@export var dano_minimo_por_golpe : float = 10.0
@export var dano_maximo_por_golpe : float = 40.0

## Registro del daño acumulado.
var dano_actual : float = 0.0

func calcular_dano(fuerza: float) -> void:
	# Cuanto más rápido el choque, más daño (interpolado entre mínimo y máximo).
	var proporcion : float = clampf(fuerza / fuerza_referencia, 0.0, 1.0)
	var dano_del_golpe : float = lerpf(dano_minimo_por_golpe, dano_maximo_por_golpe, proporcion)
	dano_actual = minf(dano_actual + dano_del_golpe, dano_maximo)
	dano_actualizado.emit(dano_actual, dano_maximo)
