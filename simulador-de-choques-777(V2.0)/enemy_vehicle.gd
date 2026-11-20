class_name EnemyVehicle
extends CharacterBody2D
## ÚNICA responsabilidad: conducir en contramano a velocidad constante, siguiendo el suelo
## de su carril. No sabe quién lo genera ni cuándo se elimina.
## Pertenece al grupo "obstaculo" (lo declara la escena y se asegura aquí también),
## así que el `CollisionDetector` del jugador lo cuenta como choque.

@export var _sprite: Sprite2D
@export var _gravedad: float = 600.0

var _velocidad: float = 0.0
var _alineador: SurfaceAligner

func _ready() -> void:
	add_to_group(&"obstaculo")
	if _sprite == null:
		_sprite = get_node_or_null("Sprite2D") as Sprite2D
	# Mantiene la velocidad horizontal constante aunque el suelo tenga pendiente.
	floor_constant_speed = true
	_alineador = SurfaceAligner.new()
	add_child(_alineador)

## Se llama justo después de instanciar, antes o después de agregarlo al árbol.
## `mascara_suelo`: capa física del carril (suelo sobre el que circula y capa en la que "vive").
func configurar(config: TrafficConfig, textura: Texture2D, mascara_suelo: int) -> void:
	_velocidad = config.velocidad()
	collision_layer = mascara_suelo
	collision_mask = mascara_suelo
	if _sprite == null:
		_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if is_instance_valid(_sprite):
		_sprite.texture = textura
		_sprite.scale = config.escala_sprite()
		_sprite.flip_h = config.voltear_sprite()

## Velocidad (px/s) con la que este vehículo golpea. La usa el detector de choques (duck typing).
func velocidad_de_impacto() -> float:
	return _velocidad

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravedad * delta
	velocity.x = -_velocidad
	move_and_slide()
	_alineador.alinear(self, 10.0, delta)
