## PhysicsModifier
## ÚNICA responsabilidad: degradar los valores de movimiento del vehículo
## de forma proporcional al daño (velocidad, aceleración y manejo).
class_name PhysicsModifier
extends Node

## Cuánto se reduce cada valor al llegar al daño máximo (0.7 = queda al 30 %).
@export var reduccion_maxima : float = 0.7

func aplicar_degradacion(dano_actual: float, dano_maximo: float) -> void:
	var vehiculo : Personaje = get_parent()
	# Guardar los valores originales la primera vez, para no degradar sobre lo ya degradado.
	if not vehiculo.has_meta("fisicas_base"):
		vehiculo.set_meta("fisicas_base", {
			"max_speed": vehiculo.max_speed,
			"accel": vehiculo.accel,
			"rotation_speed": vehiculo.rotation_speed,
		})
	var base : Dictionary = vehiculo.get_meta("fisicas_base")
	var factor : float = 1.0 - clampf(dano_actual / dano_maximo, 0.0, 1.0) * reduccion_maxima
	vehiculo.max_speed = base["max_speed"] * factor
	vehiculo.accel = base["accel"] * factor
	vehiculo.rotation_speed = base["rotation_speed"] * factor
	# La velocidad de empuje se calculaba una sola vez: mantenerla ligada a max_speed.
	vehiculo.push_speed = vehiculo.max_speed * 0.6
