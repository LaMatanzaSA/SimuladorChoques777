## ÚNICA responsabilidad: dejar el vehículo inoperativo cuando el daño llega al máximo.
class_name VehicleStopper
extends Node

## Fricción aplicada al destruirse, para que frene en seco en lugar de seguir rodando.
@export var friccion_destruido : float = 1500.0

func detener_vehiculo(dano_actual: float, dano_maximo: float) -> void:
	# Mientras no se alcance el umbral, no hacer nada.
	if dano_actual < dano_maximo:
		return
	var vehiculo : Personaje = get_parent()
	# Se corta el control del jugador (la gravedad y colisiones siguen activas
	# para que el vehículo no quede flotando si se destruye en el aire).
	vehiculo.operativo = false
	vehiculo.accel = 0.0
	vehiculo.friction = friccion_destruido
	# Se apaga el detector para no seguir acumulando daño sobre un vehículo destruido.
	vehiculo.get_node("CollisionDetector").set_deferred("monitoring", false)
