class_name TerrainStreamer
extends Node2D
## ÚNICA responsabilidad: mantener una tira continua de tramos de suelo que cubra
## la zona visible, generando tramos en ambos sentidos y eliminando los que quedan
## fuera de pantalla. No conoce al jugador, a la cámara ni a los carriles:
## solo depende de `ViewBounds` (qué se ve), `SegmentCatalog` (qué generar) y
## del contrato `TerrainSegment` (cómo se enganchan los tramos).
##
## La posición global de este nodo es el punto de entrada del primer tramo.

## Un tramo nuevo, ya colocado y dentro del árbol.
signal segmento_creado(segmento: TerrainSegment)
## Un tramo que está por liberarse (salió de pantalla).
signal segmento_eliminado(segmento: TerrainSegment)

@export var _catalogo: SegmentCatalog
## Si está vacío se crea un `ViewBounds` por defecto.
@export var _limites_vista: ViewBounds
## Cuánto más allá del borde visible debe haber suelo generado.
@export var _margen_generacion: float = 128.0
## Distancia mínima fuera de pantalla para eliminar un tramo.
## Siempre se usa como mínimo `_margen_generacion`, para no generar y borrar lo mismo.
@export var _margen_eliminacion: float = 128.0
## 0 = aleatoria en cada partida.
@export var _semilla: int = 0

## Tope de tramos creados/eliminados por extremo y por fotograma (protege de bucles largos).
const _MAX_OPERACIONES_POR_PASO: int = 64

var _segmentos: Array[TerrainSegment] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _iniciado: bool = false

func _ready() -> void:
	if _semilla != 0:
		_rng.seed = _semilla
	else:
		_rng.randomize()
	if _catalogo == null or not _catalogo.es_valido():
		push_error("TerrainStreamer '%s': el catálogo de tramos está vacío." % name)
		set_process(false)
		return
	if not is_instance_valid(_limites_vista):
		_limites_vista = ViewBounds.new()
		add_child(_limites_vista)

func _process(_delta: float) -> void:
	# El primer tramo se crea aquí (no en _ready) para que quien escuche
	# `segmento_creado` ya esté conectado, sin importar el orden de los _ready.
	if not _iniciado:
		_iniciado = _crear_primer_segmento()
		if not _iniciado:
			set_process(false)
			return
	var vista: Rect2 = _limites_vista.rect_visible()
	_generar(vista)
	_eliminar(vista)

## Cantidad de tramos vivos (útil para depurar y probar).
func cantidad_segmentos() -> int:
	return _segmentos.size()

func _crear_primer_segmento() -> bool:
	var segmento: TerrainSegment = _instanciar_segmento()
	if segmento == null:
		return false
	segmento.colocar_entrada_en(global_position)
	_segmentos.push_back(segmento)
	segmento_creado.emit(segmento)
	return true

## Garantiza suelo hasta `_margen_generacion` más allá de ambos bordes visibles.
func _generar(vista: Rect2) -> void:
	var limite_derecho: float = vista.end.x + _margen_generacion
	var limite_izquierdo: float = vista.position.x - _margen_generacion
	var operaciones: int = 0
	while _segmentos.back().punto_salida().x < limite_derecho and operaciones < _MAX_OPERACIONES_POR_PASO:
		if not _anadir_a_la_derecha():
			break
		operaciones += 1
	operaciones = 0
	while _segmentos.front().punto_entrada().x > limite_izquierdo and operaciones < _MAX_OPERACIONES_POR_PASO:
		if not _anadir_a_la_izquierda():
			break
		operaciones += 1

## Elimina los tramos que quedaron completamente fuera de pantalla (más el margen).
func _eliminar(vista: Rect2) -> void:
	var margen: float = maxf(_margen_eliminacion, _margen_generacion)
	var operaciones: int = 0
	while _segmentos.size() > 1 and _segmentos.back().punto_entrada().x > vista.end.x + margen and operaciones < _MAX_OPERACIONES_POR_PASO:
		_retirar(_segmentos.size() - 1)
		operaciones += 1
	operaciones = 0
	while _segmentos.size() > 1 and _segmentos.front().punto_salida().x < vista.position.x - margen and operaciones < _MAX_OPERACIONES_POR_PASO:
		_retirar(0)
		operaciones += 1

func _anadir_a_la_derecha() -> bool:
	var segmento: TerrainSegment = _instanciar_segmento()
	if segmento == null:
		return false
	segmento.colocar_entrada_en(_segmentos.back().punto_salida())
	_segmentos.push_back(segmento)
	segmento_creado.emit(segmento)
	return true

func _anadir_a_la_izquierda() -> bool:
	var segmento: TerrainSegment = _instanciar_segmento()
	if segmento == null:
		return false
	segmento.colocar_salida_en(_segmentos.front().punto_entrada())
	_segmentos.push_front(segmento)
	segmento_creado.emit(segmento)
	return true

func _retirar(indice: int) -> void:
	var segmento: TerrainSegment = _segmentos.pop_at(indice)
	segmento_eliminado.emit(segmento)
	segmento.queue_free()

## Instancia un tramo del catálogo y lo agrega al árbol. Devuelve null si no es válido.
func _instanciar_segmento() -> TerrainSegment:
	var escena: PackedScene = _catalogo.elegir(_rng)
	if escena == null:
		push_error("TerrainStreamer '%s': el catálogo devolvió una escena nula." % name)
		return null
	var nodo: Node = escena.instantiate()
	var segmento: TerrainSegment = nodo as TerrainSegment
	if segmento == null:
		push_error("TerrainStreamer '%s': la raíz de '%s' no es un TerrainSegment." % [name, escena.resource_path])
		nodo.free()
		return null
	add_child(segmento)
	if segmento.ancho() <= 0.0:
		push_error("TerrainStreamer '%s': el tramo '%s' tiene ancho no positivo." % [name, escena.resource_path])
		segmento.queue_free()
		return null
	return segmento
