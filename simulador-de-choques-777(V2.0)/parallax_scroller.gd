class_name ParallaxScroller
extends Node
## ÚNICA responsabilidad: desplazar un ParallaxBackground según la velocidad (con signo)
## de un vehículo, con inercia. Se suscribe, por duck typing, al primer nodo del grupo
## "vehiculos" que emita `desplazamiento_horizontal`.
## Se coloca como hijo del ParallaxBackground (o se le asigna `_fondo`).

@export var _fondo: ParallaxBackground
@export var _factor: float = 1.6
@export var _inercia: float = 2.0
## Velocidad que se toma como "a fondo" para el empuje extra del fondo (la máxima del vehículo).
@export var _velocidad_referencia: float = 400.0

var _velocidad_objetivo: float = 0.0
var _velocidad_actual: float = 0.0

func _ready() -> void:
	if not is_instance_valid(_fondo):
		_fondo = get_parent() as ParallaxBackground
	if not is_instance_valid(_fondo):
		push_error("ParallaxScroller '%s': falta el ParallaxBackground." % name)
		set_physics_process(false)
		return
	_conectar_fuente()

func registrar_velocidad(velocidad: float) -> void:
	_velocidad_objetivo = velocidad

func _physics_process(delta: float) -> void:
	_velocidad_actual = lerpf(_velocidad_actual, _velocidad_objetivo, clampf(_inercia * delta, 0.0, 1.0))
	var extra: float = 1.0 + absf(_velocidad_actual) / maxf(_velocidad_referencia, 1.0)
	_fondo.scroll_base_offset.x -= _velocidad_actual * delta * _factor * extra

func _conectar_fuente() -> void:
	var fuente: Node = get_tree().get_first_node_in_group(&"vehiculos")
	if fuente == null or not fuente.has_signal(&"desplazamiento_horizontal"):
		push_warning("ParallaxScroller: no se encontró una fuente con la señal 'desplazamiento_horizontal'.")
		return
	if not fuente.is_connected(&"desplazamiento_horizontal", registrar_velocidad):
		fuente.connect(&"desplazamiento_horizontal", registrar_velocidad)
