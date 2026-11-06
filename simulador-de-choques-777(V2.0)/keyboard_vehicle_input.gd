class_name KeyboardVehicleInput
extends Node
## Fuente de dirección por teclado (ui_left / ui_right).

signal direccion_cambiada(direccion: float)

func _ready() -> void:
	# Prioridad menor = se procesa antes que el vehículo, así la dirección llega
	# en el mismo paso de física (mismo comportamiento que antes).
	process_physics_priority = -10

func _physics_process(_delta: float) -> void:
	direccion_cambiada.emit(Input.get_axis("ui_left", "ui_right"))
