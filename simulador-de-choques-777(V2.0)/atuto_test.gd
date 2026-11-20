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

@export_group("Visual y Parallax")
@export var sprite_auto: Sprite2D
@export var nodo_parallax: ParallaxBackground
@export var factor_velocidad_fondo: float = 1.6
@export var inercia_fondo: float = 2.0

var _velocidad_fondo_actual: float = 0.0
var _speed: float = 0.0
var _direccion: float = 0.0
var _is_pushing: bool = false
var _operativo: bool = true
## 1.0 = sin daño; baja cuando el vehículo se degrada.
var _factor_dano: float = 1.0
var _friccion_final: float = 0.0

func _ready() -> void:
	_buscar_referencias_faltantes()
	_aplicar_textura_auto()
	_aplicar_textura_mapa()
	
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
	
	# Movimiento del fondo con velocidad progresiva e inercia:
	if is_instance_valid(nodo_parallax):
		_velocidad_fondo_actual = lerpf(_velocidad_fondo_actual, _speed, clampf(inercia_fondo * delta, 0.0, 1.0))
		var max_vel: float = maxf(_stats.velocidad_maxima(1.0), 1.0)
		var extra_por_velocidad: float = 1.0 + (absf(_velocidad_fondo_actual) / max_vel)
		nodo_parallax.scroll_base_offset.x -= _velocidad_fondo_actual * delta * factor_velocidad_fondo * extra_por_velocidad

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

func _buscar_referencias_faltantes() -> void:
	if not is_instance_valid(sprite_auto):
		for hijo: Node in get_children():
			if hijo is Sprite2D:
				sprite_auto = hijo
				break
	if not is_instance_valid(nodo_parallax):
		nodo_parallax = get_tree().root.find_child("ParallaxBackground", true, false) as ParallaxBackground

func _aplicar_textura_auto() -> void:
	if ResourceLoader.exists(GameManager.auto_seleccionado):
		var nueva_textura: Texture2D = load(GameManager.auto_seleccionado) as Texture2D
		if is_instance_valid(sprite_auto) and nueva_textura != null:
			sprite_auto.texture = nueva_textura

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
	
func _aplicar_textura_mapa() -> void:
	if not is_instance_valid(nodo_parallax):
		push_warning("No se encontró ParallaxBackground en la escena.")
		return
	if not ResourceLoader.exists(GameManager.mapa_seleccionado):
		push_warning("No existe el mapa en la ruta: " + GameManager.mapa_seleccionado)
		return
		
	var nueva_textura: Texture2D = load(GameManager.mapa_seleccionado) as Texture2D
	var sprites: Array[Node] = nodo_parallax.find_children("*", "Sprite2D", true, false)
	if not sprites.is_empty() and nueva_textura != null:
		(sprites[0] as Sprite2D).texture = nueva_textura
