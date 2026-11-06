class_name MenuPausa
extends CanvasLayer
## ÚNICA responsabilidad: alternar la pausa y avisarlo por señal.
## El panel lo anima PanelSlideAnimator (hijo) escuchando `pausa_cambiada`.

signal pausa_cambiada(activa: bool)

@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"
@export var _ruta_boton_continuar: NodePath = ^"UI/VBoxContainer/BotonContinuar"
@export var _ruta_boton_reiniciar: NodePath = ^"UI/VBoxContainer/BotonReiniciar"
@export var _ruta_boton_salir: NodePath = ^"UI/VBoxContainer/BotonSalir"

var _flujo: SceneFlow

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_flujo = SceneFlow.new(get_tree(), _ruta_menu_principal)
	_asegurar_animador()
	_conectar_boton(_ruta_boton_continuar, toggle_pausa)
	_conectar_boton(_ruta_boton_reiniciar, _flujo.reiniciar)
	_conectar_boton(_ruta_boton_salir, _flujo.ir_al_menu_principal)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa() -> void:
	var activa: bool = not get_tree().paused
	get_tree().paused = activa
	pausa_cambiada.emit(activa)

## Si la escena no trae un animador (cualquier hijo con `entrar()`), se agrega uno.
func _asegurar_animador() -> void:
	for hijo: Node in get_children():
		if hijo.has_method(&"entrar"):
			return
	add_child(PanelSlideAnimator.new())

func _conectar_boton(ruta: NodePath, accion: Callable) -> void:
	var boton: Node = get_node_or_null(ruta)
	if boton != null and boton.has_signal(&"pressed"):
		boton.connect(&"pressed", accion)
