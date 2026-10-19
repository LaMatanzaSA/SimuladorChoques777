extends CanvasLayer

@export_file("*.tscn") var ruta_escena_juego: String = "res://Prueba.tscn"

@onready var vbox: VBoxContainer = get_node_or_null("UI/VBoxContainer")
@onready var boton_iniciar: Button = get_node_or_null("UI/VBoxContainer/BotonIniciar")
@onready var boton_salir: Button = get_node_or_null("UI/VBoxContainer/BotonSalir")

func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	
	# Forzamos tamaño mínimo a los botones para que nunca colapsen a 0
	if is_instance_valid(vbox):
		vbox.custom_minimum_size = Vector2(200, 100)
		vbox.add_theme_constant_override("separation", 10)
		for child in vbox.get_children():
			if child is Button:
				child.custom_minimum_size = Vector2(200, 40)

	if is_instance_valid(boton_iniciar):
		boton_iniciar.pressed.connect(func(): get_tree().change_scene_to_file(ruta_escena_juego))
	if is_instance_valid(boton_salir):
		boton_salir.pressed.connect(func(): get_tree().quit())
