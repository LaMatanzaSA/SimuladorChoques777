class_name SurfaceAligner
extends Node
## ÚNICA responsabilidad: rotar el cuerpo según la pendiente del suelo.

var _rotacion_objetivo: float = 0.0

func alinear(cuerpo: CharacterBody2D, velocidad_rotacion: float, delta: float) -> void:
	if cuerpo.is_on_floor():
		_rotacion_objetivo = cuerpo.get_floor_normal().angle() + PI / 2.0
	elif cuerpo.velocity.y < -50.0:
		_rotacion_objetivo = 0.0
	cuerpo.rotation = lerp_angle(cuerpo.rotation, _rotacion_objetivo, velocidad_rotacion * delta)
