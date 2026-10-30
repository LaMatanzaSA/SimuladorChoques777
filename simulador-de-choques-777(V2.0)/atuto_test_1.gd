class_name Personaje
extends CharacterBody2D
## Responsabilidad: integrar movimiento horizontal + gravedad.
## Input, alineación, empuje y UI están delegados en componentes/señales.

signal velocidad_cambiada(velocidad: float)

@export var stats: VehicleStats
@export var entrada: VehicleInput
@export var alineador: SurfaceAligner
@export var empujador: VehiclePusher

## Copia mutable de `stats`: el .tres original nunca se modifica.
var stats_actual: VehicleStats
var speed: float = 0.0
var is_pushing: bool = false
## false cuando el vehículo está destruido.
var operativo: bool = true

func _ready() -> void:
	if stats == null:
		stats = VehicleStats.new()
	stats_actual = stats.duplicate() as VehicleStats
	if entrada == null:
		entrada = _agregar(KeyboardVehicleInput.new()) as VehicleInput
	if alineador == null:
		alineador = _agregar(SurfaceAligner.new()) as SurfaceAligner
	if empujador == null:
		empujador = _agregar(VehiclePusher.new()) as VehiclePusher

func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_actualizar_velocidad_horizontal(delta)
	move_and_slide()
	alineador.alinear(self, stats_actual.rotation_speed, delta)
	is_pushing = empujador.empujar(self, speed, stats_actual.fuerza_empuje)
	velocidad_cambiada.emit(absf(speed))

## Deja el vehículo sin control; lo invoca VehicleStopper.
func inhabilitar(friccion_final: float) -> void:
	operativo = false
	stats_actual.accel = 0.0
	stats_actual.friction = friccion_final

func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += stats_actual.gravity * delta

func _actualizar_velocidad_horizontal(delta: float) -> void:
	var tope: float = stats_actual.velocidad_empuje() if is_pushing else stats_actual.max_speed
	var direccion: float = entrada.obtener_direccion() if operativo else 0.0
	if direccion != 0.0:
		speed = move_toward(speed, direccion * tope, stats_actual.accel * delta)
	else:
		speed = move_toward(speed, 0.0, stats_actual.friction * delta)
	velocity.x = speed

func _agregar(nodo: Node) -> Node:
	add_child(nodo)
	return nodo
