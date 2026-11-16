class_name LaneBodyFollower
extends Node
## ÚNICA responsabilidad: mantener un CharacterBody2D sincronizado con el carril elegido.
## - Su máscara de colisión incluye solo la capa física del carril actual.
## - Al cambiar de carril lo desplaza verticalmente con suavidad. Durante el viaje no colisiona
##   con ningún carril (así no se incrusta en el suelo del carril destino) y al llegar recupera
##   la colisión del carril nuevo.
## Depende de `CharacterBody2D` (tipo base de Godot), no de `Personaje`.

@export var _cuerpo: CharacterBody2D
@export var _controlador: LaneController

## Máscara del cuerpo sin ninguna capa de carril (obstáculos, objetos con física, etc.).
var _mascara_base: int = 0
var _y_destino: float = 0.0
var _tween: Tween

func _ready() -> void:
	if _cuerpo == null:
		_cuerpo = get_parent() as CharacterBody2D
	if _cuerpo == null or _controlador == null:
		push_error("LaneBodyFollower '%s': falta asignar el cuerpo o el controlador." % name)
		return
	_mascara_base = _cuerpo.collision_mask & ~_controlador.configuracion().mascara_total()
	_asignar_carril_actual()
	_controlador.carril_cambiado.connect(_on_carril_cambiado)

func _on_carril_cambiado(indice_anterior: int, indice_nuevo: int) -> void:
	var config: LaneConfig = _controlador.configuracion()
	var salto: float = config.desplazamiento_y(indice_nuevo) - config.desplazamiento_y(indice_anterior)
	var y_inicial: float = _cuerpo.global_position.y
	# Si ya viajaba, el nuevo destino se acumula sobre el anterior; si no, parte de donde está.
	_y_destino = (_y_destino if _tween != null and _tween.is_valid() else y_inicial) + salto
	_cuerpo.collision_mask = _mascara_base
	# Velocidad constante: cruzar varios carriles tarda proporcionalmente más.
	var duracion: float = config.duracion_transicion() * absf(_y_destino - y_inicial) / maxf(config.separacion(), 1.0)
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_method(_aplicar_altura, y_inicial, _y_destino, maxf(duracion, 0.01))
	_tween.tween_callback(_asignar_carril_actual)

func _aplicar_altura(y: float) -> void:
	_cuerpo.global_position.y = y
	# La gravedad no debe acumularse mientras se viaja entre carriles.
	_cuerpo.velocity.y = 0.0

func _asignar_carril_actual() -> void:
	_cuerpo.collision_mask = _mascara_base | _controlador.configuracion().mascara_de(_controlador.indice_actual())
