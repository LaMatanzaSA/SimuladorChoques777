class_name PantallaMuerte
extends CanvasLayer
## ÚNICA responsabilidad: mostrar la pantalla de derrota.
## Depende de cualquier nodo que emita `auto_destruido`, no de una clase concreta.

## Fuente explícita (opcional). Si está vacía se buscan fuentes por grupo.
@export var _fuente_destruccion: Node
@export_file("*.tscn") var _ruta_menu_principal: String = "res://menu_inicio.tscn"
@export var _ruta_boton_reiniciar: NodePath = ^"UI/VBoxContainer/BotonReiniciar"
@export var _ruta_boton_menu: NodePath = ^"UI/VBoxContainer/BotonMenu"
@export var _ruta_label_velocidad: NodePath = ^"UI/VBoxContainer/LabelVelocidad"

var _flujo: SceneFlow

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_flujo = SceneFlow.new(get_tree(), _ruta_menu_principal)
	_alternar_visibilidad(false)
	_conectar_boton(_ruta_boton_reiniciar, _flujo.reiniciar)
	_conectar_boton(_ruta_boton_menu, _flujo.ir_al_menu_principal)
	_conectar_fuentes()

## Muestra la pantalla sin pausar el árbol del juego.
func mostrar_muerte() -> void:
	var label_vel: Label = get_node_or_null(_ruta_label_velocidad) as Label
	if is_instance_valid(label_vel):
		var fuerza_redondeada: int = roundi(GameManager.fuerza_ultimo_choque)
		label_vel.text = "Fuerza del impacto: %d N" % fuerza_redondeada
		
	_alternar_visibilidad(true)
	get_tree().call_group(&"menu_pausa", &"bloquear_pausa")
		
	_alternar_visibilidad(true)
	get_tree().call_group(&"menu_pausa", &"bloquear_pausa")

func _alternar_visibilidad(mostrar: bool) -> void:
	for hijo: Node in get_children():
		if hijo is CanvasItem:
			(hijo as CanvasItem).visible = mostrar

func _conectar_boton(ruta: NodePath, accion: Callable) -> void:
	var boton: Node = get_node_or_null(ruta)
	if boton != null and boton.has_signal(&"pressed"):
		boton.connect(&"pressed", accion)

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
