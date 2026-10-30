class_name SceneFlow
extends RefCounted
## ÚNICA responsabilidad: transiciones de escena compartidas por todos los menús.

static func restablecer_estado(arbol: SceneTree) -> void:
	Engine.time_scale = 1.0
	arbol.paused = false

static func reiniciar_escena(arbol: SceneTree) -> void:
	arbol.paused = false
	arbol.reload_current_scene()

static func cambiar_escena(arbol: SceneTree, ruta: String) -> void:
	arbol.paused = false
	arbol.change_scene_to_file(ruta)
