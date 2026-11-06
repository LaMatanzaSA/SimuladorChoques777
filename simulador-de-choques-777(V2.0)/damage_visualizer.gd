class_name DamageVisualizer
extends Node
## ÚNICA responsabilidad: reflejar el nivel de daño en el aspecto visual del vehículo.
## Contrato de reacción al daño: `reaccionar_al_dano(dano_actual, dano_maximo)`.

@export var _config: DamageVisualConfig
@export var _sprite: Sprite2D

func _ready() -> void:
	if _config == null:
		_config = DamageVisualConfig.new()
	if _sprite == null:
		_sprite = get_parent().get_node_or_null("Sprite2D") as Sprite2D

func reaccionar_al_dano(dano_actual: float, dano_maximo: float) -> void:
	if not is_instance_valid(_sprite):
		return
	var proporcion: float = clampf(dano_actual / dano_maximo, 0.0, 1.0)
	var textura: Texture2D = _config.textura_para(proporcion)
	if textura != null:
		_sprite.texture = textura
	_sprite.modulate = _config.color_para(proporcion)
