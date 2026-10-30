class_name MenuPausa
extends CanvasLayer
## ÚNICA responsabilidad: alternar la pausa y atender sus botones.

@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"
@export var _animador: PanelSlideAnimator

@onready var _ui_contenedor: Control = $UI
@onready var _boton_continuar: Button = $UI/VBoxContainer/BotonContinuar
@onready var _boton_reiniciar: Button = $UI/VBoxContainer/BotonReiniciar
@onready var _boton_salir: Button = $UI/VBoxContainer/BotonSalir

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _animador == null:
		_animador = PanelSlideAnimator.new()
		_animador.panel = _ui_contenedor
		add_child(_animador)
	_animador.inicializar()
	_conectar_senales()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa() -> void:
	var nuevo_estado: bool = not get_tree().paused
	get_tree().paused = nuevo_estado
	if nuevo_estado:
		_animador.entrar()
	else:
		_animador.salir()

func _conectar_senales() -> void:
	if is_instance_valid(_boton_continuar):
		_boton_continuar.pressed.connect(toggle_pausa)
	if is_instance_valid(_boton_reiniciar):
		_boton_reiniciar.pressed.connect(func() -> void: SceneFlow.reiniciar_escena(get_tree()))
	if is_instance_valid(_boton_salir):
		_boton_salir.pressed.connect(func() -> void: SceneFlow.cambiar_escena(get_tree(), _ruta_menu_principal))
