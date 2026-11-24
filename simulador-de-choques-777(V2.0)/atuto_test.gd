class_name Personaje
extends CharacterBody2D
## ÚNICA responsabilidad: integrar movimiento horizontal + gravedad.
## Todo lo demás vive en componentes hijos: ensamblado en `VehicleWiring`, empuje en
## `VehiclePusher`, inclinación en `SurfaceAligner`, aspecto en `VehicleSkin` y
## scroll del fondo en `ParallaxScroller`. El grupo "vehiculos" está en AtutoTest.tscn.

## Velocidad absoluta (la usan el velocímetro y el detector de choques).
signal velocidad_cambiada(velocidad: float)
## Velocidad horizontal CON signo (la usa, por ejemplo, el scroll del fondo).
signal desplazamiento_horizontal(velocidad: float)
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
	_ensamblar_componentes()

func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_actualizar_velocidad_horizontal(delta)
	move_and_slide()
	_alineador.alinear(self, _stats.velocidad_rotacion(_factor_dano), delta)
	_is_pushing = _empujador.empujar(self, signf(_speed), _stats.fuerza_empuje())
	if _is_pushing:
		velocity.y = 0.0
	velocidad_cambiada.emit(absf(_speed))
	desplazamiento_horizontal.emit(_speed)

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

func _ensamblar_componentes() -> void:
	var cableado: VehicleWiring = VehicleWiring.new(self)
	_alineador = cableado.obtener_o_crear(SurfaceAligner, _alineador) as SurfaceAligner
	_empujador = cableado.obtener_o_crear(VehiclePusher, _empujador) as VehiclePusher
	cableado.obtener_o_crear(VehicleSkin, null)
	cableado.asegurar_fuente_de_direccion(_ENTRADA_POR_DEFECTO)
	cableado.conectar_hijos(&"direccion_cambiada", establecer_direccion)
	cableado.conectar_hijos(&"degradacion_calculada", aplicar_degradacion)
	cableado.conectar_hijos(&"vehiculo_destruido", inhabilitar)

func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _stats.gravedad() * delta

func _actualizar_velocidad_horizontal(delta: float) -> void:
	var direccion: float = _direccion if _operativo else 0.0
	if direccion != 0.0:
		_speed = move_toward(_speed, direccion * _tope_de_velocidad(), _stats.aceleracion(_factor_dano) * delta)
	else:
		_speed = move_toward(_speed, 0.0, _friccion_actual() * delta)
	velocity.x = _speed

func _tope_de_velocidad() -> float:
	if _is_pushing:
		return _stats.velocidad_empuje(_factor_dano)
	return _stats.velocidad_maxima(_factor_dano)

func _friccion_actual() -> float:
	return _stats.friccion() if _operativo else _friccion_final
