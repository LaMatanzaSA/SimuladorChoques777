class_name MenuPausa
extends CanvasLayer

@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"
@export var _animador: PanelSlideAnimator

# Contenedor principal y paneles secundarios
@onready var _ui_contenedor: Control = $UI
@onready var _menu_principal_vbox: Control = $UI/VBoxContainer
@onready var _panel_mapas: Control = $UI/PanelMapas
@onready var _panel_autos: Control = $UI/PanelAutos

# Botones del menú principal
@onready var _boton_continuar: Button = $UI/VBoxContainer/BotonContinuar
@onready var _boton_mapas: Button = $UI/VBoxContainer/BotonMapas
@onready var _boton_autos: Button = $UI/VBoxContainer/BotonAutos
@onready var _boton_reiniciar: Button = $UI/VBoxContainer/BotonReiniciar
@onready var _boton_salir: Button = $UI/VBoxContainer/BotonSalir

# Botones del panel de Mapas
@onready var _boton_mapa_1: Button = $UI/PanelMapas/BotonMapa1
@onready var _boton_mapa_2: Button = $UI/PanelMapas/BotonMapa2
@onready var _boton_mapa_3: Button = $UI/PanelMapas/BotonMapa3
@onready var _boton_volver_mapas: Button = $UI/PanelMapas/BotonVolverMapas

# Botones del panel de Autos
@onready var _boton_auto_1: Button = $UI/PanelAutos/BotonAuto1
@onready var _boton_auto_2: Button = $UI/PanelAutos/BotonAuto2
@onready var _boton_auto_3: Button = $UI/PanelAutos/BotonAuto3
@onready var _boton_volver_autos: Button = $UI/PanelAutos/BotonVolverAutos
@onready var _pausa_bloqueada: bool = false

func _ready() -> void:
	add_to_group(&"menu_pausa")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if _animador == null:
		_animador = PanelSlideAnimator.new()
		add_child(_animador)
	
	if is_instance_valid(_animador):
		_animador.panel = _ui_contenedor
		_animador.inicializar()
		
	_mostrar_submenu(null) # Deja visible únicamente el menú de pausa principal
	_conectar_senales()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()
	if not _pausa_bloqueada:
		return
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()

func toggle_pausa() -> void:
	var nuevo_estado: bool = not get_tree().paused
	get_tree().paused = nuevo_estado
	if nuevo_estado:
		_mostrar_submenu(null)
		if is_instance_valid(_animador):
			_animador.entrar()
	else:
		if is_instance_valid(_animador):
			_animador.salir()

func _mostrar_submenu(sub_panel: Control) -> void:
	if is_instance_valid(_menu_principal_vbox):
		_menu_principal_vbox.visible = (sub_panel == null)
	if is_instance_valid(_panel_mapas):
		_panel_mapas.visible = (sub_panel == _panel_mapas)
	if is_instance_valid(_panel_autos):
		_panel_autos.visible = (sub_panel == _panel_autos)

func _conectar_senales() -> void:
	# Navegación principal
	if is_instance_valid(_boton_continuar):
		_boton_continuar.pressed.connect(toggle_pausa)
	if is_instance_valid(_boton_mapas):
		_boton_mapas.pressed.connect(func() -> void: _mostrar_submenu(_panel_mapas))
	if is_instance_valid(_boton_autos):
		_boton_autos.pressed.connect(func() -> void: _mostrar_submenu(_panel_autos))
	if is_instance_valid(_boton_reiniciar):
		_boton_reiniciar.pressed.connect(func() -> void: SceneFlow.reiniciar_escena(get_tree()))
	if is_instance_valid(_boton_salir):
		_boton_salir.pressed.connect(func() -> void: SceneFlow.cambiar_escena(get_tree(), _ruta_menu_principal))

	# Botones de regreso
	if is_instance_valid(_boton_volver_mapas):
		_boton_volver_mapas.pressed.connect(func() -> void: _mostrar_submenu(null))
	if is_instance_valid(_boton_volver_autos):
		_boton_volver_autos.pressed.connect(func() -> void: _mostrar_submenu(null))

	# Selección de Mapas
	if is_instance_valid(_boton_mapa_1):
		_boton_mapa_1.pressed.connect(func() -> void: _seleccionar_mapa("res://Sprites/FONDOS REALES/MUNDO 1.png"))
	if is_instance_valid(_boton_mapa_2):
		_boton_mapa_2.pressed.connect(func() -> void: _seleccionar_mapa("res://Sprites/FONDOS REALES/MUNDO 2.png"))
	if is_instance_valid(_boton_mapa_3):
		_boton_mapa_3.pressed.connect(func() -> void: _seleccionar_mapa("res://Sprites/FONDOS REALES/MUNDO 3.png"))

	# Selección de Autos
	if is_instance_valid(_boton_auto_1):
		_boton_auto_1.pressed.connect(func() -> void: _seleccionar_auto("res://Sprites/Cars/taxi.png"))
	if is_instance_valid(_boton_auto_2):
		_boton_auto_2.pressed.connect(func() -> void: _seleccionar_auto("res://Sprites/Cars/sports_yellow.png"))
	if is_instance_valid(_boton_auto_3):
		_boton_auto_3.pressed.connect(func() -> void: _seleccionar_auto("res://Sprites/Cars/sports_race.png"))

func _seleccionar_mapa(ruta_mapa: String) -> void:
	GameManager.mapa_seleccionado = ruta_mapa
	SceneFlow.reiniciar_escena(get_tree())

func _seleccionar_auto(ruta_auto: String) -> void:
	GameManager.auto_seleccionado = ruta_auto
	SceneFlow.reiniciar_escena(get_tree())

func bloquear_pausa() -> void:
	_pausa_bloqueada = true
	if get_tree().paused:
		get_tree().paused = false
		if is_instance_valid(_animador) and _animador.has_method("salir"):
			_animador.salir()
