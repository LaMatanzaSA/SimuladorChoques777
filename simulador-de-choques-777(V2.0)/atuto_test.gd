class_name Personaje

extends CharacterBody2D
## Responsabilidad: integrar movimiento horizontal + gravedad.
## El ensamblado de componentes vive en `VehicleWiring`, el empuje (incluida la
## lectura de contactos) en `VehiclePusher` y el grupo "vehiculos" en AtutoTest.tscn.

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

func _ready() -> void:
	if _stats == null:
		_stats = VehicleStats.new()
	var cableado: VehicleWiring = VehicleWiring.new(self)
	_alineador = cableado.obtener_o_crear(SurfaceAligner, _alineador) as SurfaceAligner
	_empujador = cableado.obtener_o_crear(VehiclePusher, _empujador) as VehiclePusher
	cableado.asegurar_fuente_de_direccion(_ENTRADA_POR_DEFECTO)
	cableado.conectar_hijos(&"direccion_cambiada", establecer_direccion)
	cableado.conectar_hijos(&"degradacion_calculada", aplicar_degradacion)
	cableado.conectar_hijos(&"vehiculo_destruido", inhabilitar)

func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_actualizar_velocidad_horizontal(delta)
	move_and_slide()
	_alineador.alinear(self, _stats.velocidad_rotacion(_factor_dano), delta)
	_is_pushing = _empujador.empujar(self, signf(_speed), _stats.fuerza_empuje())
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
