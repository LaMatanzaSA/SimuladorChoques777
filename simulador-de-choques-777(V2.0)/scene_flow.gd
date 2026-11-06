class_name SceneFlow
extends RefCounted
## Servicio de navegación entre escenas. Ya no es una utilidad estática: cada menú
## recibe su propia instancia con el árbol y la ruta del menú principal inyectados.

## Se emite justo antes de cambiar de escena.
signal escena_solicitada(ruta: String)

var _arbol: SceneTree
var _ruta_menu_principal: String

func _init(arbol: SceneTree, ruta_menu_principal: String = "res://menu_inicio.tscn") -> void:
	_arbol = arbol
	_ruta_menu_principal = ruta_menu_principal

func restablecer_estado() -> void:
	Engine.time_scale = 1.0
	_arbol.paused = false

func reiniciar() -> void:
	_arbol.paused = false
	_arbol.reload_current_scene()

func ir_al_menu_principal() -> void:
	cambiar_a(_ruta_menu_principal)

func cambiar_a(ruta: String) -> void:
	_arbol.paused = false
	escena_solicitada.emit(ruta)
	_arbol.change_scene_to_file(ruta)
