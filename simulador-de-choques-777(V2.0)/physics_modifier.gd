class_name PhysicsModifier
extends Node
## ÚNICA responsabilidad: traducir el daño en un factor de desgaste de las físicas.
## Contrato de reacción al daño: `reaccionar_al_dano(dano_actual, dano_maximo)`.

## Factor en (0, 1]: 1.0 = sin desgaste.
signal degradacion_calculada(factor: float)

## Cuánto se reduce cada valor al llegar al daño máximo (0.7 = queda al 30 %).
@export_range(0.0, 1.0) var _reduccion_maxima: float = 0.7

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	var factor: float = 1.0 - clampf(dano_actual / dano_maximo, 0.0, 1.0) * _reduccion_maxima
	degradacion_calculada.emit(factor)
