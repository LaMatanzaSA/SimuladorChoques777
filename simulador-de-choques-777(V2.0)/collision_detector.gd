class_name CollisionDetector
extends Area2D
## ÚNICA responsabilidad: detectar choques con obstáculos y avisar la fuerza.
## No conoce la clase del vehículo: se suscribe por duck typing a cualquier nodo
## que exponga la señal `velocidad_cambiada(float)`.

signal impacto_detectado(fuerza: float)

## Nodo que emite `velocidad_cambiada`. Si está vacío se usa el padre.
@export var fuente_velocidad: Node
## Grupo que identifica a los cuerpos que cuentan como obstáculo.
@export var grupo_obstaculo: StringName = &"obstaculo"
## Por debajo de esta velocidad el roce no cuenta como choque.
@export var velocidad_minima: float = 60.0

var _velocidad_actual: float = 0.0

func _ready() -> void:
	# Conexiones idempotentes: funcionan igual si la escena ya las traía.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not is_instance_valid(fuente_velocidad):
		fuente_velocidad = get_parent()
	_suscribirse_a(fuente_velocidad)

func registrar_velocidad(velocidad: float) -> void:
	_velocidad_actual = absf(velocidad)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(grupo_obstaculo):
		return
	if _velocidad_actual < velocidad_minima:
		return
	impacto_detectado.emit(_velocidad_actual)

func _suscribirse_a(fuente: Node) -> void:
	if not is_instance_valid(fuente) or not fuente.has_signal(&"velocidad_cambiada"):
		push_warning("CollisionDetector: no se encontró una fuente con la señal 'velocidad_cambiada'.")
		return
	if not fuente.is_connected(&"velocidad_cambiada", registrar_velocidad):
		fuente.connect(&"velocidad_cambiada", registrar_velocidad)
