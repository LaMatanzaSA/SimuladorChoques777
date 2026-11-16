class_name LaneInput
extends Node
## ÚNICA responsabilidad: traducir las teclas ↑ / ↓ en solicitudes de cambio de carril.
## Emite una solicitud por pulsación (sin repetición al mantener). Quien la reciba decide
## si es válida: esta clase no conoce los límites.

## -1 = carril superior, +1 = carril inferior.
signal desplazamiento_solicitado(direccion: int)

@export var _accion_arriba: StringName = &"ui_up"
@export var _accion_abajo: StringName = &"ui_down"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_accion_arriba):
		desplazamiento_solicitado.emit(-1)
	elif event.is_action_pressed(_accion_abajo):
		desplazamiento_solicitado.emit(1)
