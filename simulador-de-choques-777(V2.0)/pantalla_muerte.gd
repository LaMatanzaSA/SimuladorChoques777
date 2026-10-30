class_name PantallaMuerte
extends CanvasLayer
## ÚNICA responsabilidad: mostrar la pantalla de derrota.
## Depende de cualquier nodo que emita `auto_destruido`

## Fuente explícita (opcional). Si está vacía se buscan fuentes por grupo.
@export var _fuente_destruccion: Node
@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"

@onready var _fondo_rojo: ColorRect = $FondoRojo
@onready var _ui_contenedor: Control = $UI
@onready var _boton_reiniciar: Button = $UI/VBoxContainer/BotonReiniciar
@onready var _boton_menu: Button = $UI/VBoxContainer/BotonMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_alternar_visibilidad(false)
	_conectar_senales_ui()
	_conectar_fuentes()

## Muestra la pantalla sin pausar el árbol del juego.
func mostrar_muerte() -> void:
	_alternar_visibilidad(true)

func _alternar_visibilidad(mostrar: bool) -> void:
	if is_instance_valid(_fondo_rojo):
		_fondo_rojo.visible = mostrar
	if is_instance_valid(_ui_contenedor):
		_ui_contenedor.visible = mostrar

func _conectar_senales_ui() -> void:
	if is_instance_valid(_boton_reiniciar):
		_boton_reiniciar.pressed.connect(func() -> void: SceneFlow.reiniciar_escena(get_tree()))
	if is_instance_valid(_boton_menu):
		_boton_menu.pressed.connect(func() -> void: SceneFlow.cambiar_escena(get_tree(), _ruta_menu_principal))

## Se conecta a la fuente explícita o, si no hay, a todas las del grupo.
func _conectar_fuentes() -> void:
	var fuentes: Array[Node] = []
	if is_instance_valid(_fuente_destruccion):
		fuentes.append(_fuente_destruccion)
	else:
		fuentes.append_array(get_tree().get_nodes_in_group(&"fuentes_destruccion"))
	var conectadas: int = 0
	for fuente: Node in fuentes:
		if not fuente.has_signal(&"auto_destruido"):
			continue
		if not fuente.is_connected(&"auto_destruido", mostrar_muerte):
			fuente.connect(&"auto_destruido", mostrar_muerte)
		conectadas += 1
	if conectadas == 0:
		push_warning("PantallaMuerte: no se encontró ninguna fuente con la señal 'auto_destruido'.")
