class_name Velocimetro
extends Control

## Componentes visuales
@export var _aguja_sprite: Sprite2D
@export var _texto_velocidad: Label

## Configuración del tablero
@export_group("Configuracion de Angulo")
@export var _angulo_minimo_grados: float = -32.0
@export var _angulo_maximo_grados: float = 212.0

@export_group("Configuracion de Escala")
@export var _velocidad_maxima: float = 400.0
@export var _kmh_maximo_tablero: float = 240.0

## Estado interno privado
var _velocidad_actual: float = 0.0

func _ready() -> void:
	_validar_referencias()
	_conectar_fuente()

func actualizar_velocidad(nueva_velocidad: float) -> void:
	_velocidad_actual = maxf(0.0, nueva_velocidad)

func _process(_delta: float) -> void:
	_actualizar_rotacion_aguja()
	_actualizar_texto_velocidad()

func _actualizar_rotacion_aguja() -> void:
	if not is_instance_valid(_aguja_sprite):
		return
	var porcentaje: float = clampf(_velocidad_actual / _velocidad_maxima, 0.0, 1.0)
	_aguja_sprite.rotation_degrees = lerpf(_angulo_minimo_grados, _angulo_maximo_grados, porcentaje)

func _actualizar_texto_velocidad() -> void:
	if not is_instance_valid(_texto_velocidad):
		return
	_texto_velocidad.text = str(roundi((_velocidad_actual / _velocidad_maxima) * _kmh_maximo_tablero))

func _validar_referencias() -> void:
	if not is_instance_valid(_aguja_sprite):
		_aguja_sprite = get_node_or_null(^"Agujavelocidad") as Sprite2D

## Se suscribe, por duck typing, al primer nodo del grupo "vehiculos" que emita `velocidad_cambiada`.
func _conectar_fuente() -> void:
	var fuente := get_tree().get_first_node_in_group(&"vehiculos")
	if fuente == null or not fuente.has_signal(&"velocidad_cambiada"):
		push_warning("Velocimetro: no se encontró una fuente con la señal 'velocidad_cambiada'.")
		return
	if not fuente.is_connected(&"velocidad_cambiada", actualizar_velocidad):
		fuente.connect(&"velocidad_cambiada", actualizar_velocidad)
