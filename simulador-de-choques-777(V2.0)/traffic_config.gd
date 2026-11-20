class_name TrafficConfig
extends Resource
## Datos del tráfico enemigo (autos en contramano). Se inyecta como Resource (.tres):
## agregar o quitar sprites, cambiar la velocidad o la frecuencia es editar este recurso.

@export_group("Sprites")
## Lista de sprites posibles. Cada auto que aparece elige uno al azar.
@export var _sprites: Array[Texture2D] = []
## Pesos opcionales (uno por sprite). Si no coinciden en cantidad, todos son equiprobables.
@export var _pesos: PackedFloat32Array = PackedFloat32Array()
## Escala del sprite (el auto del jugador usa aprox. (2.05, 2.57)).
@export var _escala_sprite: Vector2 = Vector2(2.0454545, 2.5714285)
## Los sprites del jugador miran a la derecha: los enemigos van hacia la izquierda, así que se voltean.
@export var _voltear_sprite: bool = true

@export_group("Movimiento")
## Velocidad constante en contramano, en px/s (siempre hacia la izquierda).
@export var _velocidad: float = 200.0

@export_group("Aparición")
## Segundos mínimo y máximo entre apariciones (se sortea cada vez).
@export var _intervalo_minimo: float = 1.5
@export var _intervalo_maximo: float = 4.0
## Distancia horizontal mínima entre dos autos del mismo carril al aparecer.
@export var _distancia_minima_mismo_carril: float = 300.0
## Cuánto más allá del borde derecho de la pantalla aparece el auto.
@export var _margen_aparicion: float = 64.0
## Distancia fuera de pantalla (a la izquierda) a la que el auto se elimina.
@export var _margen_eliminacion: float = 256.0
## Tope de autos enemigos vivos a la vez.
@export var _maximo_simultaneos: int = 6

func es_valido() -> bool:
	return not _sprites.is_empty()

func velocidad() -> float:
	return absf(_velocidad)

func escala_sprite() -> Vector2:
	return _escala_sprite

func voltear_sprite() -> bool:
	return _voltear_sprite

func distancia_minima_mismo_carril() -> float:
	return _distancia_minima_mismo_carril

func margen_aparicion() -> float:
	return _margen_aparicion

func margen_eliminacion() -> float:
	return _margen_eliminacion

func maximo_simultaneos() -> int:
	return maxi(_maximo_simultaneos, 1)

## Sprite al azar de la lista (con pesos si están bien configurados). Null si no hay sprites.
func textura_aleatoria(rng: RandomNumberGenerator) -> Texture2D:
	if _sprites.is_empty():
		return null
	if _pesos.size() != _sprites.size():
		return _sprites[rng.randi_range(0, _sprites.size() - 1)]
	return _sprites[rng.rand_weighted(_pesos)]

## Segundos hasta la próxima aparición.
func proximo_intervalo(rng: RandomNumberGenerator) -> float:
	var minimo: float = maxf(minf(_intervalo_minimo, _intervalo_maximo), 0.1)
	var maximo: float = maxf(maxf(_intervalo_minimo, _intervalo_maximo), minimo)
	return rng.randf_range(minimo, maximo)
