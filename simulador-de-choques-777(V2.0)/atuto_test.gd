class_name Personaje
extends CharacterBody2D
## Responsabilidad: integrar movimiento horizontal + gravedad.

signal velocidad_cambiada(velocidad: float)
## Se emite una única vez, cuando el vehículo queda inhabilitado.
signal destruido
## Fuente de dirección que se crea si la escena no aporta ninguna.
const _ENTRADA_POR_DEFECTO: GDScript = preload("res://keyboard_vehicle_input.gd")

@export var _stats: VehicleStats
@export var _alineador: SurfaceAligner
@export var _empujador: VehiclePusher

var _speed: float = 0.0
var _direccion: float = 0.0
var _is_pushing: bool = false
var _operativo: bool = true
## 1.0 = sin daño; baja cuando el vehículo se degrada.
var _factor_dano: float = 1.0
var _friccion_final: float = 0.0

func _enter_tree() -> void:
	# Antes de cualquier _ready(): la UI puede encontrar al vehículo sin depender del orden del árbol.
	add_to_group(&"vehiculos")

func _ready() -> void:
	if _stats == null:
		_stats = VehicleStats.new()
	_alineador = _obtener_o_crear(SurfaceAligner, _alineador) as SurfaceAligner
	_empujador = _obtener_o_crear(VehiclePusher, _empujador) as VehiclePusher
	_asegurar_fuente_de_direccion()
	_conectar_hijos(&"direccion_cambiada", establecer_direccion)
	_conectar_hijos(&"degradacion_calculada", aplicar_degradacion)
	_conectar_hijos(&"vehiculo_destruido", inhabilitar)

func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_actualizar_velocidad_horizontal(delta)
	move_and_slide()
	_alineador.alinear(self, _stats.velocidad_rotacion(_factor_dano), delta)
	_is_pushing = _empujador.empujar(_cuerpos_en_contacto(), signf(_speed), _stats.fuerza_empuje())
	if _is_pushing:
		velocity.y = 0.0
	velocidad_cambiada.emit(absf(_speed))

## Dirección deseada en [-1, 1].
func establecer_direccion(direccion: float) -> void:
	_direccion = direccion

## Factor de desgaste en (0, 1]: escala velocidad máxima, aceleración y giro.
func aplicar_degradacion(factor: float) -> void:
	_factor_dano = factor

## Deja el vehículo sin control y lo frena con la fricción indicada.
func inhabilitar(friccion_final: float) -> void:
	if not _operativo:
		return
	_operativo = false
	_friccion_final = friccion_final
	destruido.emit()

func esta_operativo() -> bool:
	return _operativo

func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _stats.gravedad() * delta

func _actualizar_velocidad_horizontal(delta: float) -> void:
	var tope: float = _stats.velocidad_empuje(_factor_dano) if _is_pushing else _stats.velocidad_maxima(_factor_dano)
	var direccion: float = _direccion if _operativo else 0.0
	if direccion != 0.0:
		_speed = move_toward(_speed, direccion * tope, _stats.aceleracion(_factor_dano) * delta)
	else:
		var friccion: float = _stats.friccion() if _operativo else _friccion_final
		_speed = move_toward(_speed, 0.0, friccion * delta)
	velocity.x = _speed

func _cuerpos_en_contacto() -> Array[Object]:
	var cuerpos: Array[Object] = []
	for i: int in get_slide_collision_count():
		cuerpos.append(get_slide_collision(i).get_collider())
	return cuerpos

## Devuelve el componente inyectado, uno existente del mismo tipo, o uno nuevo.
func _obtener_o_crear(tipo: GDScript, actual: Node) -> Node:
	if is_instance_valid(actual):
		return actual
	for hijo: Node in get_children():
		if is_instance_of(hijo, tipo):
			return hijo
	var nuevo: Node = tipo.new()
	add_child(nuevo)
	return nuevo

func _asegurar_fuente_de_direccion() -> void:
	for hijo: Node in get_children():
		if hijo.has_signal(&"direccion_cambiada"):
			return
	add_child(_ENTRADA_POR_DEFECTO.new() as Node)

func _conectar_hijos(senal: StringName, receptor: Callable) -> void:
	for hijo: Node in get_children():
		if hijo.has_signal(senal) and not hijo.is_connected(senal, receptor):
			hijo.connect(senal, receptor)
