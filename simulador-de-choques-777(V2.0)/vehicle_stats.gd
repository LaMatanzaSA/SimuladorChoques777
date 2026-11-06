class_name VehicleStats
extends Resource
## Datos de movimiento del vehículo. Se inyecta como Resource (.tres).
## Los campos son privados: el resto del código consulta valores mediante métodos
## y el desgaste por daño se aplica como un factor, de modo que el recurso nunca se modifica.

@export var _max_speed: float = 400.0
@export var _accel: float = 800.0
@export var _friction: float = 600.0
@export var _rotation_speed: float = 10.0
@export var _gravity: float = 300.0
@export var _fuerza_empuje: float = 50.0
@export_range(0.0, 1.0) var _ratio_velocidad_empuje: float = 0.6

## Velocidad máxima, escalada por el factor de desgaste (1.0 = sin daño).
func velocidad_maxima(factor: float = 1.0) -> float:
	return _max_speed * factor

## Tope de velocidad mientras se empuja un objeto.
func velocidad_empuje(factor: float = 1.0) -> float:
	return velocidad_maxima(factor) * _ratio_velocidad_empuje

func aceleracion(factor: float = 1.0) -> float:
	return _accel * factor

func velocidad_rotacion(factor: float = 1.0) -> float:
	return _rotation_speed * factor

func friccion() -> float:
	return _friction

func gravedad() -> float:
	return _gravity

func fuerza_empuje() -> float:
	return _fuerza_empuje
