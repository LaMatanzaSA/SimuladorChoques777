class_name CollisionDetector
extends Area2D
## ÚNICA responsabilidad: detectar choques con obstáculos y avisar la fuerza.
## No conoce la clase del vehículo: se suscribe por duck typing a las señales
## `velocidad_cambiada(float)` y `destruido` de su fuente (por defecto, el padre).

signal impacto_detectado(fuerza: float)

## Nodo que emite las señales del vehículo. Si está vacío se usa el padre.
@export var _fuente_velocidad: Node
## Grupo que identifica a los cuerpos que cuentan como obstáculo.
@export var _grupo_obstaculo: StringName = &"obstaculo"
## Por debajo de esta velocidad el roce no cuenta como choque.
@export var _velocidad_minima: float = 60.0

var _velocidad_actual: float = 0.0

func _ready() -> void:
	# Conexiones idempotentes: funcionan igual si la escena ya las traía.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not is_instance_valid(_fuente_velocidad):
		_fuente_velocidad = get_parent()
	_suscribirse(&"velocidad_cambiada", registrar_velocidad)
	_suscribirse(&"destruido", desactivar)

func registrar_velocidad(velocidad: float) -> void:
	_velocidad_actual = absf(velocidad)

## Deja de contar choques (el vehículo ya está destruido).
func desactivar() -> void:
	set_deferred(&"monitoring", false)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(_grupo_obstaculo):
		return
	if _velocidad_actual < _velocidad_minima:
		return
	impacto_detectado.emit(_velocidad_actual)

func _suscribirse(senal: StringName, receptor: Callable) -> void:
	if not is_instance_valid(_fuente_velocidad) or not _fuente_velocidad.has_signal(senal):
		push_warning("CollisionDetector: la fuente no tiene la señal '%s'." % senal)
		return
	if not _fuente_velocidad.is_connected(senal, receptor):
		_fuente_velocidad.connect(senal, receptor)
