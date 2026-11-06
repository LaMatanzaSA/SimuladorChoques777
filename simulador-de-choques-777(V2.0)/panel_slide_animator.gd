class_name PanelSlideAnimator
extends Node
## ÚNICA responsabilidad: deslizar un panel dentro/fuera de la pantalla.
## Escucha una señal booleana de su padre (por defecto `pausa_cambiada(activa)`): no es invocado.

## Ruta al panel (relativa a este nodo).
@export var _ruta_panel: NodePath = ^"../UI"
@export var _duracion: float = 0.3
## Señal del padre que activa (true) o desactiva (false) el panel.
@export var _senal_activacion: StringName = &"pausa_cambiada"

var _panel: Control
var _posicion_visible: Vector2 = Vector2.ZERO
var _posicion_oculta: Vector2 = Vector2.ZERO
var _tween: Tween

func _ready() -> void:
	_panel = get_node_or_null(_ruta_panel) as Control
	if _panel == null:
		push_warning("PanelSlideAnimator: no se encontró el panel en '%s'." % _ruta_panel)
		return
	_posicion_visible = _panel.position
	_posicion_oculta = _posicion_visible + Vector2(get_viewport().get_visible_rect().size.x, 0.0)
	_panel.position = _posicion_oculta
	_panel.hide()
	_suscribirse_al_padre()

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
