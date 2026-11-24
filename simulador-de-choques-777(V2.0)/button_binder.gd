class_name ButtonBinder
extends RefCounted
## ÚNICA responsabilidad: conectar botones de un contenedor con acciones.
## Evita una variable y una conexión a mano por cada botón de un menú.

## Conecta cada botón hijo (buscado por nombre) con su acción. Ignora los que no existan.
## `acciones`: { "NombreBoton": Callable }
func conectar_por_nombre(contenedor: Node, acciones: Dictionary) -> void:
	if not is_instance_valid(contenedor):
		return
	for nombre: String in acciones.keys():
		var boton: BaseButton = contenedor.get_node_or_null(NodePath(nombre)) as BaseButton
		var accion: Callable = acciones[nombre]
		if boton != null and not boton.pressed.is_connected(accion):
			boton.pressed.connect(accion)

## Conecta los botones cuyo nombre empieza con `prefijo` (en el orden en que están en el
## contenedor) con `accion`, pasándole como argumento la ruta que les corresponda en `rutas`.
func conectar_opciones(contenedor: Node, prefijo: String, rutas: PackedStringArray, accion: Callable) -> void:
	if not is_instance_valid(contenedor):
		return
	var indice: int = 0
	for hijo: Node in contenedor.get_children():
		if indice >= rutas.size():
			break
		if hijo is BaseButton and String(hijo.name).begins_with(prefijo):
			(hijo as BaseButton).pressed.connect(accion.bind(rutas[indice]))
			indice += 1
