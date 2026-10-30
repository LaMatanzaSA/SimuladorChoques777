class_name DamageCalculator
extends Node
## ÚNICA responsabilidad: acumular daño según la fuerza del impacto.

## Se emite cada vez que cambia el daño acumulado.
signal dano_actualizado(dano_actual: float, dano_maximo: float)
## Se emite cuando el vehículo queda destruido.
signal auto_destruido

@export var config: DamageConfig
## Nodo que emite `impacto_detectado(float)`. Si está vacío se busca entre los hermanos.
@export var fuente_impactos: Node

var dano_actual: float = 0.0

func _enter_tree() -> void:
	# Antes de cualquier _ready(), para que otros nodos puedan encontrarlo por grupo.
	add_to_group(&"fuentes_destruccion")
	# Grupo histórico: mantiene compatible a cualquier script anterior que lo busque.
	add_to_group(&"damage_calculators")

func _ready() -> void:
	if config == null:
		config = DamageConfig.new()
	if not is_instance_valid(fuente_impactos):
		fuente_impactos = _buscar_fuente_impactos()
	if not is_instance_valid(fuente_impactos) or not fuente_impactos.has_signal(&"impacto_detectado"):
		push_warning("DamageCalculator: no se encontró una fuente con la señal 'impacto_detectado'.")
		return
	if not fuente_impactos.is_connected(&"impacto_detectado", calcular_dano):
		fuente_impactos.connect(&"impacto_detectado", calcular_dano)

func calcular_dano(fuerza: float) -> void:
	var proporcion: float = clampf(fuerza / config.fuerza_referencia, 0.0, 1.0)
	var dano_del_golpe: float = lerpf(config.dano_minimo_por_golpe, config.dano_maximo_por_golpe, proporcion)
	dano_actual = minf(dano_actual + dano_del_golpe, config.dano_maximo)
	dano_actualizado.emit(dano_actual, config.dano_maximo)
	if dano_actual >= config.dano_maximo:
		auto_destruido.emit()

func _buscar_fuente_impactos() -> Node:
	var padre: Node = get_parent()
	if padre == null:
		return null
	for hermano: Node in padre.get_children():
		if hermano != self and hermano.has_signal(&"impacto_detectado"):
			return hermano
	return null
