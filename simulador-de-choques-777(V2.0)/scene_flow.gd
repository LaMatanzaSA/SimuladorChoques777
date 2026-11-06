class_name SceneFlow
extends RefCounted
## Servicio de navegación entre escenas (soporta instancias y llamadas estáticas).

signal escena_solicitada(ruta: String)

var _arbol: SceneTree
var _ruta_menu_principal: String

func _init(arbol: SceneTree = null, ruta_menu_principal: String = "res://menu_inicio.tscn") -> void:
	_arbol = arbol
	_ruta_menu_principal = ruta_menu_principal

func restablecer_estado() -> void:
	Engine.time_scale = 1.0
	if is_instance_valid(_arbol):
		_arbol.paused = false

func ir_al_menu_principal() -> void:
	cambiar_a(_ruta_menu_principal)

func reiniciar() -> void:
	if is_instance_valid(_arbol):
		Engine.time_scale = 1.0
		_arbol.paused = false
		_arbol.reload_current_scene()

func cambiar_a(ruta: String) -> void:
	if is_instance_valid(_arbol):
		Engine.time_scale = 1.0
		_arbol.paused = false
		escena_solicitada.emit(ruta)
		_arbol.change_scene_to_file(ruta)

# --- Métodos estáticos para llamadas directas sin instanciar ---

static func reiniciar_escena(arbol: SceneTree) -> void:
	if is_instance_valid(arbol):
		Engine.time_scale = 1.0
		arbol.paused = false
		arbol.reload_current_scene()

static func cambiar_escena(arbol: SceneTree, ruta: String) -> void:
	if is_instance_valid(arbol) and ruta != "":
		Engine.time_scale = 1.0
		arbol.paused = false
		arbol.change_scene_to_file(ruta)
