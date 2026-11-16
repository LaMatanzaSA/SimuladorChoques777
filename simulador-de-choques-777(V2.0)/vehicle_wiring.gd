class_name VehicleWiring
extends RefCounted
## ÚNICA responsabilidad: ensamblar los componentes hijos de un vehículo
## (reutilizar o crear cada componente y conectar sus señales con el cuerpo).
## Existe para que `Personaje` se limite a mover el vehículo.

var _cuerpo: Node

func _init(cuerpo: Node) -> void:
	_cuerpo = cuerpo

## Devuelve el componente inyectado, uno existente del mismo tipo, o uno nuevo.
func obtener_o_crear(tipo: GDScript, actual: Node) -> Node:
	if is_instance_valid(actual):
		return actual
	for hijo: Node in _cuerpo.get_children():
		if is_instance_of(hijo, tipo):
			return hijo
	var nuevo: Node = tipo.new()
	_cuerpo.add_child(nuevo)
	return nuevo

## Garantiza que exista una fuente de dirección; si no hay ninguna, crea la de `por_defecto`.
func asegurar_fuente_de_direccion(por_defecto: GDScript) -> void:
	for hijo: Node in _cuerpo.get_children():
		if hijo.has_signal(&"direccion_cambiada"):
			return
	_cuerpo.add_child(por_defecto.new() as Node)

## Conecta `senal` de cada hijo que la declare con `receptor` (idempotente).
func conectar_hijos(senal: StringName, receptor: Callable) -> void:
	for hijo: Node in _cuerpo.get_children():
		if hijo.has_signal(senal) and not hijo.is_connected(senal, receptor):
			hijo.connect(senal, receptor)
