class_name VehicleStopper
extends Node
## ÚNICA responsabilidad: decidir cuándo el vehículo queda destruido y avisarlo.

signal vehiculo_destruido(friccion_final: float)

## Fricción aplicada al destruirse, para que frene en seco.
@export var _friccion_destruido: float = 1500.0

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	if dano_actual >= dano_maximo:
		vehiculo_destruido.emit(_friccion_destruido)
