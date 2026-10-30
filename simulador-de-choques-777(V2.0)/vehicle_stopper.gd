## ÚNICA responsabilidad: dejar el vehículo inoperativo cuando el daño llega al máximo.
class_name VehicleStopper
extends DamageReactor

## Fricción aplicada al destruirse, para que frene en seco.
@export var friccion_destruido: float = 1500.0
@export var vehiculo: Personaje
@export var detector: Area2D

func _ready() -> void:
	super()
	if vehiculo == null:
		vehiculo = get_parent() as Personaje
	if detector == null and is_instance_valid(vehiculo):
		for hijo: Node in vehiculo.get_children():
			if hijo is CollisionDetector:
				detector = hijo as Area2D
				break

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	if dano_actual < dano_maximo:
		return
	vehiculo.inhabilitar(friccion_destruido)
	# Se apaga el detector para no seguir acumulando daño sobre un vehículo destruido.
	if is_instance_valid(detector):
		detector.set_deferred("monitoring", false)
