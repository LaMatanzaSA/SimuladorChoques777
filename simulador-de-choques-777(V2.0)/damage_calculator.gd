class_name DamageCalculator
extends Node
## ÚNICA responsabilidad: acumular daño según la fuerza del impacto y anunciarlo.

## Se emite cada vez que cambia el daño acumulado.
signal dano_actualizado(dano_actual: float, dano_maximo: float)
## Se emite cuando el vehículo queda destruido.
signal auto_destruido

@export var _config: DamageConfig
## Nodo que emite `impacto_detectado(float)`. Si está vacío se busca entre los hermanos.
@export var _fuente_impactos: Node

var _dano_actual: float = 0.0

func _enter_tree() -> void:
	# Antes de cualquier _ready(), para que otros nodos puedan encontrarlo por grupo.
	add_to_group(&"fuentes_destruccion")
	# Grupo histórico: mantiene compatible a cualquier script anterior que lo busque.
	add_to_group(&"damage_calculators")

func _ready() -> void:
	if _config == null:
		_config = DamageConfig.new()
	_conectar_fuente_de_impactos()
	_conectar_reactores()

func calcular_dano(fuerza: float) -> void:
	_dano_actual = _config.acumular(_dano_actual, fuerza)
	dano_actualizado.emit(_dano_actual, _config.dano_maximo())
	if _config.es_letal(_dano_actual):
		auto_destruido.emit()

func dano_acumulado() -> float:
	return _dano_actual

func _conectar_fuente_de_impactos() -> void:
	if not is_instance_valid(_fuente_impactos):
		_fuente_impactos = _buscar_hermano_con_senal(&"impacto_detectado")
	if not is_instance_valid(_fuente_impactos):
		push_warning("DamageCalculator: no se encontró una fuente con la señal 'impacto_detectado'.")
		return
	if not _fuente_impactos.is_connected(&"impacto_detectado", calcular_dano):
		_fuente_impactos.connect(&"impacto_detectado", calcular_dano)

func _conectar_reactores() -> void:
	var padre: Node = get_parent()
	if padre == null:
		return
	for hermano: Node in padre.get_children():
		if hermano == self or not hermano.has_method(&"reaccionar_al_dano"):
			continue
		var reaccion: Callable = Callable(hermano, &"reaccionar_al_dano")
		if not dano_actualizado.is_connected(reaccion):
			dano_actualizado.connect(reaccion)

func _buscar_hermano_con_senal(senal: StringName) -> Node:
	var padre: Node = get_parent()
	if padre == null:
		return null
	for hermano: Node in padre.get_children():
		if hermano != self and hermano.has_signal(senal):
			return hermano
	return null
