extends Control

## Búsqueda flexible de aguja y label
@onready var aguja_sprite: Sprite2D = get_node_or_null("Agujavelocidad")

@export var texto_velocidad: Label

@export var angulo_minimo_grados: float = -32.0
@export var angulo_maximo_grados: float = 212.0
@export var velocidad_maxima: float = 400.0
@export var kmh_maximo_tablero: float = 240.0

var _velocidad_actual: float = 0.0

func _ready() -> void:
	# Autodetectar aguja si no está asignada por nombre
	if not is_instance_valid(aguja_sprite):
		for child in get_children():
			if child is Sprite2D:
				aguja_sprite = child
				break

	# Autodetectar Label de texto si la variable exportada está vacía
	if not is_instance_valid(texto_velocidad):
		for child in get_children():
			if child is Label:
				texto_velocidad = child
				break

func actualizar_velocidad(velocidad: float) -> void:
	_velocidad_actual = velocidad

func _process(_delta: float) -> void:
	_actualizar_rotacion_aguja()
	_actualizar_texto_velocidad()

func _actualizar_rotacion_aguja() -> void:
	if not is_instance_valid(aguja_sprite):
		return
		
	var porcentaje: float = clampf(_velocidad_actual / velocidad_maxima, 0.0, 1.0)
	var angulo_grados: float = lerpf(angulo_minimo_grados, angulo_maximo_grados, porcentaje)
	
	aguja_sprite.rotation_degrees = angulo_grados

func _actualizar_texto_velocidad() -> void:
	if not is_instance_valid(texto_velocidad):
		return
		
	var kmh_calculado: int = roundi((_velocidad_actual / velocidad_maxima) * kmh_maximo_tablero)
	texto_velocidad.text = str(kmh_calculado)
