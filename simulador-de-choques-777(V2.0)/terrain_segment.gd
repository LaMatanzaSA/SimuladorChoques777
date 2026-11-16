class_name TerrainSegment
extends StaticBody2D
## Contrato de un tramo de suelo: sabe dónde se engancha con el tramo anterior
## (`PuntoEntrada`) y con el siguiente (`PuntoSalida`). Quien genera terreno solo
## depende de este contrato, no del aspecto ni de la forma concreta del tramo:
## una rampa o un bache heredan/reemplazan la escena y mueven su punto de salida.

@export var _entrada: Marker2D
@export var _salida: Marker2D

func _ready() -> void:
	if _entrada == null or _salida == null:
		push_error("TerrainSegment '%s': faltan los Marker2D de entrada/salida." % name)

## Posición global donde empieza el tramo.
func punto_entrada() -> Vector2:
	return _entrada.global_position

## Posición global donde debe empezar el siguiente tramo.
func punto_salida() -> Vector2:
	return _salida.global_position

## Longitud horizontal del tramo.
func ancho() -> float:
	return _salida.global_position.x - _entrada.global_position.x

## Mueve el tramo para que su entrada coincida con `punto`.
func colocar_entrada_en(punto: Vector2) -> void:
	global_position += punto - _entrada.global_position

## Mueve el tramo para que su salida coincida con `punto`.
func colocar_salida_en(punto: Vector2) -> void:
	global_position += punto - _salida.global_position
