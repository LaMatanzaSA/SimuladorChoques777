class_name MenuPausa
extends CanvasLayer

## Configuración de rutas
@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"

## Tiempos de animación
@export var _duracion_animacion: float = 0.3

## Referencias a nodos UI (Encapsuladas y Tipadas)
@onready var _ui_contenedor: Control = $UI
@onready var _panel_pausa: Control = $UI/Panel # Asegurate que este sea el contenedor violeta
@onready var _boton_continuar: Button = $UI/VBoxContainer/BotonContinuar
@onready var _boton_reiniciar: Button = $UI/VBoxContainer/BotonReiniciar
@onready var _boton_salir: Button = $UI/VBoxContainer/BotonSalir

## Variables internas de posición
var _posicion_original: Vector2 = Vector2.ZERO
var _posicion_oculta: Vector2 = Vector2.ZERO
var _tween_animacion: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_guardar_posiciones_animacion()
	_ocultar_menu_instantaneo()
	_conectar_senales()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa() -> void:
	var nuevo_estado_pausa: bool = not get_tree().paused
	get_tree().paused = nuevo_estado_pausa
	
	if nuevo_estado_pausa:
		_animar_entrada()
	else:
		_animar_salida()

func _guardar_posiciones_animacion() -> void:
	if is_instance_valid(_ui_contenedor):
		# Guardamos la posición visible actual
		_posicion_original = _ui_contenedor.position
		# Calculamos la posición desplazada a la derecha fuera de la pantalla
		var ancho_pantalla: float = get_viewport().get_visible_rect().size.x
		_posicion_oculta = _posicion_original + Vector2(ancho_pantalla, 0)

func _animar_entrada() -> void:
	if not is_instance_valid(_ui_contenedor):
		return
		
	_ui_contenedor.show()
	_cancelar_tween_activo()
	
	_tween_animacion = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_animacion.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween_animacion.tween_property(_ui_contenedor, "position", _posicion_original, _duracion_animacion)

func _animar_salida() -> void:
	if not is_instance_valid(_ui_contenedor):
		return
		
	_cancelar_tween_activo()
	
	_tween_animacion = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_animacion.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween_animacion.tween_property(_ui_contenedor, "position", _posicion_oculta, _duracion_animacion)
	_tween_animacion.tween_callback(_ui_contenedor.hide)

func _ocultar_menu_instantaneo() -> void:
	if is_instance_valid(_ui_contenedor):
		_ui_contenedor.position = _posicion_oculta
		_ui_contenedor.hide()

func _cancelar_tween_activo() -> void:
	if _tween_animacion and _tween_animacion.is_running():
		_tween_animacion.kill()

func _conectar_senales() -> void:
	if is_instance_valid(_boton_continuar):
		_boton_continuar.pressed.connect(_on_continuar_pressed)
		
	if is_instance_valid(_boton_reiniciar):
		_boton_reiniciar.pressed.connect(_on_reiniciar_pressed)
		
	if is_instance_valid(_boton_salir):
		_boton_salir.pressed.connect(_on_salir_pressed)

func _on_continuar_pressed() -> void:
	toggle_pausa()

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_salir_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(_ruta_menu_principal)
