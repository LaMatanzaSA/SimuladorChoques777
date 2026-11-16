class_name PanelSlideAnimator
extends Node
## ÚNICA responsabilidad: deslizar un panel dentro/fuera de la pantalla.
## Quien lo use decide cuándo llamar a `entrar()` / `salir()`.

@export var _ruta_panel: NodePath = ^"../UI"
@export var _duracion: float = 0.3

## Panel a animar. Al asignarlo se memoriza su posición visible y se lo deja oculto.
var panel: Control:
	get:
		return _panel
	set(value):
		_panel = value
		inicializar()

var _panel: Control
var _posicion_visible: Vector2 = Vector2.ZERO
var _posicion_oculta: Vector2 = Vector2.ZERO
var _posicion_guardada: bool = false
var _tween: Tween

func _ready() -> void:
	if _panel == null:
		_panel = get_node_or_null(_ruta_panel) as Control
	inicializar()

## Memoriza la posición visible (solo la primera vez) y deja el panel oculto fuera de pantalla.
func inicializar() -> void:
	if not is_instance_valid(_panel) or _posicion_guardada:
		return
	_posicion_visible = _panel.position
	_posicion_oculta = _posicion_visible + Vector2(get_viewport().get_visible_rect().size.x, 0.0)
	_posicion_guardada = true
	_panel.position = _posicion_oculta
	_panel.hide()

func entrar() -> void:
	if not is_instance_valid(_panel):
		return
	_panel.show()
	_deslizar_a(_posicion_visible, Tween.EASE_OUT)

func salir() -> void:
	if not is_instance_valid(_panel):
		return
	_deslizar_a(_posicion_oculta, Tween.EASE_IN).tween_callback(_panel.hide)

## Reemplaza cualquier animación en curso por un deslizamiento hacia `destino`.
func _deslizar_a(destino: Vector2, suavizado: Tween.EaseType) -> Tween:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(suavizado)
	_tween.tween_property(_panel, "position", destino, _duracion)
	return _tween
