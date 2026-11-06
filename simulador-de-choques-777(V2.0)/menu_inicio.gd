class_name MenuInicio
extends CanvasLayer

## Configuración de rutas
@export_file("*.tscn") var _ruta_escena_juego: String = "res://Prueba.tscn"

## Referencias a nodos del menú
@onready var _vbox_contenedor: VBoxContainer = $UI/VBoxContainer
@onready var _boton_iniciar: Button = $UI/VBoxContainer/BotonIniciar
@onready var _boton_salir: Button = $UI/VBoxContainer/BotonSalir

var _flujo: SceneFlow

func _ready() -> void:
	_flujo = SceneFlow.new(get_tree())
	_flujo.restablecer_estado()
	_configurar_interfaz()
	_conectar_senales()

func _configurar_interfaz() -> void:
	if not is_instance_valid(_vbox_contenedor):
		return
	_vbox_contenedor.custom_minimum_size = Vector2(200, 100)
	_vbox_contenedor.add_theme_constant_override("separation", 10)
	_configurar_estilo_boton(_boton_iniciar)
	_configurar_estilo_boton(_boton_salir)

func _configurar_estilo_boton(boton: Button) -> void:
	if is_instance_valid(boton):
		boton.custom_minimum_size = Vector2(200, 40)

func _conectar_senales() -> void:
	if is_instance_valid(_boton_iniciar):
		_boton_iniciar.pressed.connect(_on_boton_iniciar_pressed)
	if is_instance_valid(_boton_salir):
		_boton_salir.pressed.connect(_on_boton_salir_pressed)

func _on_boton_iniciar_pressed() -> void:
	_flujo.cambiar_a(_ruta_escena_juego)

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
