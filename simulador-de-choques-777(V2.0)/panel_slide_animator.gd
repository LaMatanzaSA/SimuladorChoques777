class_name PanelSlideAnimator
extends Node
## ÚNICA responsabilidad: deslizar un panel dentro/fuera de la pantalla.

@export var panel: Control
@export var duracion: float = 0.3

var _posicion_visible: Vector2 = Vector2.ZERO
var _posicion_oculta: Vector2 = Vector2.ZERO
var _tween: Tween

## Se llama una vez desde el dueño, cuando el panel ya está en su posición final.
func inicializar() -> void:
	if not is_instance_valid(panel):
		return
	_posicion_visible = panel.position
	var ancho: float = get_viewport().get_visible_rect().size.x
	_posicion_oculta = _posicion_visible + Vector2(ancho, 0.0)
	panel.position = _posicion_oculta
	panel.hide()

func entrar() -> void:
	if not is_instance_valid(panel):
		return
	panel.show()
	_cancelar_tween()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(panel, "position", _posicion_visible, duracion)

func salir() -> void:
	if not is_instance_valid(panel):
		return
	_cancelar_tween()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(panel, "position", _posicion_oculta, duracion)
	_tween.tween_callback(panel.hide)

func _cancelar_tween() -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
