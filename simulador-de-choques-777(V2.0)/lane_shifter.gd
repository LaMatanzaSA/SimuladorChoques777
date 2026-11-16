class_name LaneShifter
extends Node
## ÚNICA responsabilidad: desplazar verticalmente UN nodo 2D (por ejemplo, una capa de
## fondo) para acompañar el cambio de carril. Es reutilizable: una instancia por capa,
## cada una con su propio `_factor` de paralaje.
##
## Como la cámara sigue al auto, al bajar de carril el mundo parece subir en pantalla.
## El fondo, que está fijo a la pantalla, se mueve en sentido contrario al cambio de carril
## (`_factor` > 0) para sentirse parte de ese mismo movimiento. 1.0 = igual que el suelo
## (fondo cercano), valores menores = fondo más lejano, 0 = no se mueve.

@export var _objetivo: Node2D
@export var _controlador: LaneController
@export var _factor: float = 0.5

var _y_base: float = 0.0
var _tween: Tween

func _ready() -> void:
	if not is_instance_valid(_objetivo) or _controlador == null:
		push_error("LaneShifter '%s': falta asignar el objetivo o el controlador." % name)
		return
	# La posición del objetivo en la escena corresponde al carril inicial.
	_y_base = _objetivo.position.y
	_controlador.carril_cambiado.connect(_on_carril_cambiado)

func _on_carril_cambiado(_indice_anterior: int, indice_nuevo: int) -> void:
	var config: LaneConfig = _controlador.configuracion()
	var recorrido: float = config.desplazamiento_y(indice_nuevo) - config.desplazamiento_y(config.indice_inicial())
	if _tween != null:
		_tween.kill()
	# Mismo modo de proceso que el seguidor del cuerpo: ambos avanzan en el mismo paso de física.
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_objetivo, "position:y", _y_base - recorrido * _factor, config.duracion_transicion())
