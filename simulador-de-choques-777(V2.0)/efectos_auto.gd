class_name EfectosAuto
extends GPUParticles2D

## Umbral de daño para activar el humo (20%)
@export var _umbral_humo: float = 20.0

## Referencia al nodo AnimatedSprite2D de la explosión
@export var _animacion_explosion: AnimatedSprite2D

var _damage_calculator: DamageCalculator

func _ready() -> void:
	emitting = false
	amount_ratio = 0.0
	
	if is_instance_valid(_animacion_explosion):
		_animacion_explosion.visible = false
		# Conectamos la señal que avisa cuando la animación llega al final
		_animacion_explosion.animation_finished.connect(_on_explosion_finalizada)
		
	_conectar_calculador_dano()

func _conectar_calculador_dano() -> void:
	var calculadores: Array[Node] = get_tree().get_nodes_in_group("damage_calculators")
	if not calculadores.is_empty():
		_damage_calculator = calculadores[0] as DamageCalculator
		_damage_calculator.dano_actualizado.connect(_on_dano_actualizado)
		_damage_calculator.auto_destruido.connect(_on_auto_destruido)

func _on_dano_actualizado(dano_actual: float, dano_maximo: float) -> void:
	var porcentaje: float = (dano_actual / dano_maximo) * 100.0

	if porcentaje < _umbral_humo:
		emitting = false
		amount_ratio = 0.0
	else:
		emitting = true
		var progreso: float = (porcentaje - _umbral_humo) / (100.0 - _umbral_humo)
		amount_ratio = lerpf(0.2, 1.0, clampf(progreso, 0.0, 1.0))

func _on_auto_destruido() -> void:
	if is_instance_valid(_animacion_explosion):
		_animacion_explosion.visible = true
		_animacion_explosion.frame = 0 # Arranca desde el primer fotograma
		_animacion_explosion.play("default")

func _on_explosion_finalizada() -> void:
	# Oculta la explosión una vez que terminó de reproducirse
	if is_instance_valid(_animacion_explosion):
		_animacion_explosion.visible = false
