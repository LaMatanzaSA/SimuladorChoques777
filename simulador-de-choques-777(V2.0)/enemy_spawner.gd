class_name EnemySpawner
extends Node
## ÚNICA responsabilidad: hacer aparecer autos enemigos de forma aleatoria y periódica
## justo fuera de pantalla (a la derecha) y eliminarlos cuando salen por la izquierda.
## Solo depende de `ViewBounds` (qué se ve), `LaneController` (carriles y capas físicas)
## y `TrafficConfig` (datos). No conoce al jugador ni al generador de suelo.

signal enemigo_creado(enemigo: EnemyVehicle)

@export var _config: TrafficConfig
@export var _escena_enemigo: PackedScene
@export var _controlador: LaneController
## Si está vacío se crea un `ViewBounds` por defecto.
@export var _limites_vista: ViewBounds
## Nodo 2D donde se agregan los enemigos. Asignalo en el inspector (por ejemplo, un Node2D
## "Enemigos" en el nivel). Si está vacío se usa el padre, siempre que sea un Node2D.
@export var _contenedor: Node2D
## Alcance vertical (px) del rayo que busca el suelo, por encima y por debajo de la pantalla.
@export var _altura_busqueda: float = 600.0
## 0 = aleatoria en cada partida.
@export var _semilla: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _temporizador: Timer
var _enemigos: Array[EnemyVehicle] = []

func _ready() -> void:
	if _semilla != 0:
		_rng.seed = _semilla
	else:
		_rng.randomize()
	if _config == null:
		_config = TrafficConfig.new()
	if not _config.es_valido():
		push_warning("EnemySpawner '%s': la lista de sprites está vacía, no aparecerán enemigos." % name)
		set_process(false)
		return
	if _escena_enemigo == null or _controlador == null:
		push_error("EnemySpawner '%s': falta asignar la escena del enemigo o el controlador de carriles." % name)
		set_process(false)
		return
	if not is_instance_valid(_limites_vista):
		_limites_vista = ViewBounds.new()
		add_child(_limites_vista)
	if _contenedor == null:
		_contenedor = get_parent() as Node2D
	if _contenedor == null:
		push_error("EnemySpawner '%s': asigná `_contenedor` (un Node2D) en el inspector." % name)
		set_process(false)
		return
	_temporizador = Timer.new()
	_temporizador.one_shot = true
	_temporizador.timeout.connect(_on_temporizador)
	add_child(_temporizador)
	_temporizador.start(_config.proximo_intervalo(_rng))

func _process(_delta: float) -> void:
	_eliminar_fuera_de_pantalla()

func cantidad_enemigos() -> int:
	return _enemigos.size()

func _on_temporizador() -> void:
	_intentar_aparecer()
	_temporizador.start(_config.proximo_intervalo(_rng))

func _intentar_aparecer() -> void:
	if _enemigos.size() >= _config.maximo_simultaneos() or not is_instance_valid(_contenedor):
		return
	var config_carriles: LaneConfig = _controlador.configuracion()
	var indice: int = _rng.randi_range(0, config_carriles.cantidad() - 1)
	var vista: Rect2 = _limites_vista.rect_visible()
	var x: float = vista.end.x + _config.margen_aparicion()
	if not _carril_libre(indice, x):
		return
	var mascara: int = config_carriles.mascara_de(indice)
	var punto: Vector2 = _buscar_suelo(x, mascara, vista)
	if punto == Vector2.INF:
		return  # todavía no hay suelo en ese punto: se reintenta en la próxima aparición
	var enemigo: EnemyVehicle = _escena_enemigo.instantiate() as EnemyVehicle
	if enemigo == null:
		push_error("EnemySpawner '%s': la raíz de la escena del enemigo no es un EnemyVehicle." % name)
		set_process(false)
		_temporizador.stop()
		return
	enemigo.configurar(_config, _config.textura_aleatoria(_rng), mascara)
	_contenedor.add_child(enemigo)
	# Un poco por encima del suelo: la gravedad lo asienta en el primer fotograma.
	enemigo.global_position = punto + Vector2(0.0, -40.0)
	_enemigos.push_back(enemigo)
	enemigo_creado.emit(enemigo)

## true si ningún enemigo del mismo carril está demasiado cerca del punto de aparición.
func _carril_libre(indice: int, x: float) -> bool:
	var mascara: int = _controlador.configuracion().mascara_de(indice)
	for enemigo: EnemyVehicle in _enemigos:
		if enemigo.collision_layer == mascara \
				and absf(enemigo.global_position.x - x) < _config.distancia_minima_mismo_carril():
			return false
	return true

## Punto global del suelo del carril bajo `x` (rayo hacia abajo). Vector2.INF si no hay suelo.
func _buscar_suelo(x: float, mascara: int, vista: Rect2) -> Vector2:
	var espacio: PhysicsDirectSpaceState2D = _contenedor.get_world_2d().direct_space_state
	var desde: Vector2 = Vector2(x, vista.position.y - _altura_busqueda)
	var hasta: Vector2 = Vector2(x, vista.end.y + _altura_busqueda)
	var consulta: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(desde, hasta, mascara)
	var resultado: Dictionary = espacio.intersect_ray(consulta)
	if resultado.is_empty():
		return Vector2.INF
	return resultado["position"] as Vector2

func _eliminar_fuera_de_pantalla() -> void:
	if _enemigos.is_empty():
		return
	var limite: float = _limites_vista.rect_visible().position.x - _config.margen_eliminacion()
	for i: int in range(_enemigos.size() - 1, -1, -1):
		var enemigo: EnemyVehicle = _enemigos[i]
		if not is_instance_valid(enemigo):
			_enemigos.remove_at(i)
		elif enemigo.global_position.x < limite:
			_enemigos.remove_at(i)
			enemigo.queue_free()
