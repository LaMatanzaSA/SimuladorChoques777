class_name LaneTrack
extends Node2D
## ÚNICA responsabilidad: ser la pista de UN carril: se coloca a la altura del carril
## y asigna la capa física del carril a cada tramo de suelo que su generador crea.
## El generador de suelo no sabe que existen carriles; esta clase hace de puente.

@export var _controlador: LaneController
@export var _generador: TerrainStreamer
@export var _indice_carril: int = 0

func _ready() -> void:
	if _controlador == null or _generador == null:
		push_error("LaneTrack '%s': falta asignar el controlador o el generador." % name)
		return
	var config: LaneConfig = _controlador.configuracion()
	if not config.indice_valido(_indice_carril):
		push_error("LaneTrack '%s': el carril %d no existe." % [name, _indice_carril])
		return
	position.y = config.desplazamiento_y(_indice_carril)
	_generador.segmento_creado.connect(_on_segmento_creado)

func _on_segmento_creado(segmento: TerrainSegment) -> void:
	segmento.collision_layer = _controlador.configuracion().mascara_de(_indice_carril)
	segmento.collision_mask = 0
