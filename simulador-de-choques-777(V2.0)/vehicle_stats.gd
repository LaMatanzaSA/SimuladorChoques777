class_name VehicleStats
extends Resource
## Datos de movimiento del vehículo. Se inyecta como Resource (.tres).

@export var max_speed: float = 400.0
@export var accel: float = 800.0
@export var friction: float = 600.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 300.0
@export var fuerza_empuje: float = 50.0
@export_range(0.0, 1.0) var ratio_velocidad_empuje: float = 0.6

func velocidad_empuje() -> float:
	return max_speed * ratio_velocidad_empuje

## Calcula los valores degradados a partir de los originales (sin degradar sobre lo ya degradado).
func aplicar_degradacion(base: VehicleStats, factor: float) -> void:
	max_speed = base.max_speed * factor
	accel = base.accel * factor
	rotation_speed = base.rotation_speed * factor
