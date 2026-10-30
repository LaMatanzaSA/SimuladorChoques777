## ÚNICA responsabilidad: reflejar el nivel de daño en el aspecto visual del vehículo.
class_name DamageVisualizer
extends DamageReactor

@export var config: DamageVisualConfig
@export var sprite: Sprite2D

func _ready() -> void:
	super()
	if config == null:
		config = DamageVisualConfig.new()
	if sprite == null:
		sprite = get_parent().get_node_or_null("Sprite2D") as Sprite2D

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	if not is_instance_valid(sprite):
		return
	var proporcion: float = clampf(dano_actual / dano_maximo, 0.0, 1.0)
	if not config.sprites_dano.is_empty():
		var indice: int = mini(int(proporcion * config.sprites_dano.size()), config.sprites_dano.size() - 1)
		if config.sprites_dano[indice] != null:
			sprite.texture = config.sprites_dano[indice]
	sprite.modulate = Color.WHITE.lerp(config.color_destruido, proporcion)
