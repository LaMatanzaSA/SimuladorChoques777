class_name DamageReactor
extends Node
## Contrato común: todo lo que reacciona al daño hereda de aquí.
## Para añadir una reacción nueva (sonido, partículas) basta con crear una subclase
## que sobrescriba `reaccionar_al_dano` y llame a `super()` en su `_ready()`.
##
## La suscripción es automática (duck typing): se conecta a cualquier nodo que
## emita `dano_actualizado(float, float)`. No depende de las conexiones de la escena.

## Nodo que emite `dano_actualizado`. Si está vacío se busca entre los hermanos
## y, como respaldo, en el grupo "fuentes_destruccion".
@export var fuente_dano: Node

func _ready() -> void:
	if not is_instance_valid(fuente_dano):
		fuente_dano = _buscar_fuente()
	if not is_instance_valid(fuente_dano) or not fuente_dano.has_signal(&"dano_actualizado"):
		push_warning("%s: no se encontró una fuente con la señal 'dano_actualizado'." % name)
		return
	if not fuente_dano.is_connected(&"dano_actualizado", reaccionar_al_dano):
		fuente_dano.connect(&"dano_actualizado", reaccionar_al_dano)

func reaccionar_al_dano(_dano_actual: float, _dano_maximo: float) -> void:
	pass

func _buscar_fuente() -> Node:
	var padre: Node = get_parent()
	if padre != null:
		for hermano: Node in padre.get_children():
			if hermano != self and hermano.has_signal(&"dano_actualizado"):
				return hermano
	return get_tree().get_first_node_in_group(&"fuentes_destruccion")
