class_name PanelSlideAnimator
extends Node
## ÚNICA responsabilidad: deslizar un panel dentro/fuera de la pantalla.

@export var _ruta_panel: NodePath = ^"../UI"
@export var _duracion: float = 0.3
@export var _senal_activacion: StringName = &"pausa_cambiada"

var panel: Control:
	get:
		return _panel
	set(value):
		_panel = value
		if is_instance_valid(_panel):
			_configurar_panel()

var _panel: Control
var _posicion_visible: Vector2 = Vector2.ZERO
var _posicion_oculta: Vector2 = Vector2.ZERO
var _posicion_guardada: bool = false
var _tween: Tween

func _ready() -> void:
	if _panel == null:
		_panel = get_node_or_null(_ruta_panel) as Control
	if is_instance_valid(_panel):
		_configurar_panel()
	_suscribirse_al_padre()

func inicializar() -> void:
	_configurar_panel()

func _configurar_panel() -> void:
	if not is_instance_valid(_panel):
		return
	
	# Guarda la posición original visible SOLO la primera vez
	if not _posicion_guardada:
		_posicion_visible = _panel.position
		var ancho_pantalla: float = get_viewport().get_visible_rect().size.x
		_posicion_oculta = _posicion_visible + Vector2(ancho_pantalla, 0.0)
		_posicion_guardada = true
		_panel.position = _posicion_oculta
		_panel.hide()

func entrar() -> void:
	if not is_instance_valid(_panel):
		return
	_panel.show()
	_reiniciar_tween(Tween.EASE_OUT).tween_property(_panel, "position", _posicion_visible, _duracion)

func salir() -> void:
	if not is_instance_valid(_panel):
		return
	var tween: Tween = _reiniciar_tween(Tween.EASE_IN)
	tween.tween_property(_panel, "position", _posicion_oculta, _duracion)
	tween.tween_callback(_panel.hide)

func _alternar(activa: bool) -> void:
	if activa:
		entrar()
	else:
		salir()

func _suscribirse_al_padre() -> void:
	var padre: Node = get_parent()
	if padre != null and padre.has_signal(_senal_activacion) and not padre.is_connected(_senal_activacion, _alternar):
		padre.connect(_senal_activacion, _alternar)

func _reiniciar_tween(suavizado: Tween.EaseType) -> Tween:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return _tween.set_trans(Tween.TRANS_CUBIC).set_ease(suavizado)
