class_name SegmentCatalog
extends Resource
## Datos: qué tramos de suelo puede generar el terreno y con qué probabilidad.
## Agregar tramos nuevos (rampas, baches, etc.) es agregar entradas al .tres:
## ningún script necesita cambiar. Cada escena debe tener un `TerrainSegment` como raíz.

@export var _escenas: Array[PackedScene] = []
## Pesos opcionales (uno por escena). Si falta alguno, todos los tramos son equiprobables.
@export var _pesos: PackedFloat32Array = PackedFloat32Array()

func es_valido() -> bool:
	return not _escenas.is_empty() and _escenas[0] != null

## Devuelve la escena del próximo tramo, o null si el catálogo está vacío.
func elegir(rng: RandomNumberGenerator) -> PackedScene:
	if _escenas.is_empty():
		return null
	if _pesos.size() != _escenas.size():
		return _escenas[rng.randi_range(0, _escenas.size() - 1)]
	return _escenas[rng.rand_weighted(_pesos)]
