extends CanvasLayer

## Exportamos la ruta para que puedas elegir la escena desde el Inspector
@export_file("*.tscn") var ruta_menu_principal: String = "res://menu_inicio.tscn"

@onready var ui = $UI
@onready var boton_continuar = $UI/VBoxContainer/BotonContinuar
@onready var boton_salir = $UI/VBoxContainer/BotonSalir

func _ready():
	# Permite que el CanvasLayer siga procesando aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# La ventana empieza oculta
	ui.hide()
	
	# Conectar las señales de los botones por código
	boton_continuar.pressed.connect(_on_continuar_pressed)
	boton_salir.pressed.connect(_on_salir_pressed)

func _unhandled_input(event):
	# "ui_cancel" es la tecla Escape por defecto en Godot
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa():
	# Invierte el estado de pausa del juego
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# Muestra u oculta la UI según el estado
	if nuevo_estado:
		ui.show()
	else:
		ui.hide()

func _on_continuar_pressed():
	toggle_pausa()

func _on_salir_pressed():
	# 1. Es crucial despausar el árbol ANTES de cambiar de escena
	get_tree().paused = false
	
	# 2. Cambiamos a la escena del menú principal
	get_tree().change_scene_to_file(ruta_menu_principal)
