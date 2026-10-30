## ÚNICA responsabilidad: degradar los valores de movimiento del vehículo
## de forma proporcional al daño (velocidad, aceleración y manejo).
class_name PhysicsModifier
extends DamageReactor

@export var vehiculo: Personaje
## Cuánto se reduce cada valor al llegar al daño máximo (0.7 = queda al 30 %).
@export_range(0.0, 1.0) var reduccion_maxima: float = 0.7

func _ready() -> void:
	super()
	if vehiculo == null:
		vehiculo = get_parent() as Personaje

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	var factor: float = 1.0 - clampf(dano_actual / dano_maximo, 0.0, 1.0) * reduccion_maxima
	vehiculo.stats_actual.aplicar_degradacion(vehiculo.stats, factor)
