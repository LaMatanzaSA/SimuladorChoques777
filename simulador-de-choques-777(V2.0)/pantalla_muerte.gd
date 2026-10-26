class_name PantallaMuerte
extends CanvasLayer

## Referencia al calculador de daño
@export var _damage_calculator: DamageCalculator

## Configuración de rutas
@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"

## Referencias a nodos UI (Encapsuladas y Tipadas)
@onready var _fondo_rojo: ColorRect = $FondoRojo
@onready var _ui_contenedor: Control = $UI
@onready var _boton_reiniciar: Button = $UI/VBoxContainer/BotonReiniciar
@onready var _boton_menu: Button = $UI/VBoxContainer/BotonMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ocultar_pantalla()
	_conectar_senales_ui()
	_conectar_calculador_dano()

## Muestra la pantalla sin pausar el árbol del juego
func mostrar_muerte() -> void:
	_mostrar_pantalla()

func _mostrar_pantalla() -> void:
	if is_instance_valid(_fondo_rojo):
		_fondo_rojo.show()
	if is_instance_valid(_ui_contenedor):
		_ui_contenedor.show()

func _ocultar_pantalla() -> void:
	if is_instance_valid(_fondo_rojo):
		_fondo_rojo.hide()
	if is_instance_valid(_ui_contenedor):
		_ui_contenedor.hide()

func _conectar_senales_ui() -> void:
	if is_instance_valid(_boton_reiniciar):
		_boton_reiniciar.pressed.connect(_on_reiniciar_pressed)
		
	if is_instance_valid(_boton_menu):
		_boton_menu.pressed.connect(_on_menu_pressed)

func _conectar_calculador_dano() -> void:
	if not is_instance_valid(_damage_calculator):
		var calculadores: Array[Node] = get_tree().get_nodes_in_group("damage_calculators")
		if not calculadores.is_empty():
			_damage_calculator = calculadores[0] as DamageCalculator

	if is_instance_valid(_damage_calculator):
		_damage_calculator.auto_destruido.connect(mostrar_muerte)

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(_ruta_menu_principal)
