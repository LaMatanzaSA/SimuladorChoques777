class_name MenuPausa
extends CanvasLayer
## ÚNICA responsabilidad: coordinar la pausa (abrir/cerrar el panel y navegar entre sus
## submenús). El cableado de botones lo hace `ButtonBinder`, la navegación de escenas
## `SceneFlow` y la elección guardada vive en `GameManager`.

@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"
@export var _animador: PanelSlideAnimator
## Opciones de los submenús, en el mismo orden que sus botones (BotonMapa1, 2, 3...).
## Agregar un mapa o un auto es sumar un botón a la escena y una ruta acá.
@export_file("*.png") var _rutas_mapas: PackedStringArray = PackedStringArray([
	"res://Sprites/FONDOS REALES/MUNDO 1.png",
	"res://Sprites/FONDOS REALES/MUNDO 2.png",
	"res://Sprites/FONDOS REALES/MUNDO 3.png",
])
@export_file("*.png") var _rutas_autos: PackedStringArray = PackedStringArray([
	"res://Sprites/Cars/taxi.png",
	"res://Sprites/Cars/sports_yellow.png",
	"res://Sprites/Cars/sports_race.png",
])

@onready var _ui_contenedor: Control = $UI
@onready var _menu_principal_vbox: Control = $UI/VBoxContainer
@onready var _panel_mapas: Control = $UI/PanelMapas
@onready var _panel_autos: Control = $UI/PanelAutos

var _flujo: SceneFlow
var _pausa_bloqueada: bool = false

func _ready() -> void:
	add_to_group(&"menu_pausa")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flujo = SceneFlow.new(get_tree(), _ruta_menu_principal)
	_preparar_animador()
	_mostrar_submenu(null) # Deja visible únicamente el menú de pausa principal
	_conectar_senales()

func _unhandled_input(event: InputEvent) -> void:
	if _pausa_bloqueada:
		return
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa() -> void:
	if _pausa_bloqueada:
		return
	var nuevo_estado: bool = not get_tree().paused
	get_tree().paused = nuevo_estado
	if nuevo_estado:
		_mostrar_submenu(null)
		if is_instance_valid(_animador):
			_animador.entrar()
	else:
		if is_instance_valid(_animador):
			_animador.salir()

func bloquear_pausa() -> void:
	_pausa_bloqueada = true
	if get_tree().paused:
		get_tree().paused = false
		if is_instance_valid(_animador):
			_animador.salir()

func _preparar_animador() -> void:
	if _animador == null:
		_animador = PanelSlideAnimator.new()
		add_child(_animador)
	_animador.panel = _ui_contenedor
	_animador.inicializar()

## Muestra el submenú indicado; con null, el menú principal.
func _mostrar_submenu(sub_panel: Control) -> void:
	if is_instance_valid(_menu_principal_vbox):
		_menu_principal_vbox.visible = (sub_panel == null)
	if is_instance_valid(_panel_mapas):
		_panel_mapas.visible = (sub_panel == _panel_mapas)
	if is_instance_valid(_panel_autos):
		_panel_autos.visible = (sub_panel == _panel_autos)

func _conectar_senales() -> void:
	var binder: ButtonBinder = ButtonBinder.new()
	_conectar_navegacion(binder)
	_conectar_selecciones(binder)

func _conectar_navegacion(binder: ButtonBinder) -> void:
	binder.conectar_por_nombre(_menu_principal_vbox, {
		"BotonContinuar": toggle_pausa,
		"BotonMapas": _mostrar_submenu.bind(_panel_mapas),
		"BotonAutos": _mostrar_submenu.bind(_panel_autos),
		"BotonReiniciar": _flujo.reiniciar,
		"BotonSalir": _flujo.ir_al_menu_principal,
	})
	binder.conectar_por_nombre(_panel_mapas, {"BotonVolverMapas": _mostrar_submenu.bind(null)})
	binder.conectar_por_nombre(_panel_autos, {"BotonVolverAutos": _mostrar_submenu.bind(null)})

func _conectar_selecciones(binder: ButtonBinder) -> void:
	binder.conectar_opciones(_panel_mapas, "BotonMapa", _rutas_mapas, _seleccionar_mapa)
	binder.conectar_opciones(_panel_autos, "BotonAuto", _rutas_autos, _seleccionar_auto)

func _seleccionar_mapa(ruta_mapa: String) -> void:
	GameManager.cambiar_mapa(ruta_mapa)
	_flujo.reiniciar()

func _seleccionar_auto(ruta_auto: String) -> void:
	GameManager.cambiar_auto(ruta_auto)
	_flujo.reiniciar()
