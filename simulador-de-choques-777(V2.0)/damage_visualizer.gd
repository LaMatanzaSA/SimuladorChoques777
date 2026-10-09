## ÚNICA responsabilidad: reflejar el nivel de daño en el aspecto visual del vehículo.
class_name DamageVisualizer
extends Node

## Sprites de menor a mayor desgaste (p. ej. leve, medio, destruido).
## Se asignan en el Inspector. Si está vacío, solo se oscurece el sprite original.
@export var sprites_dano : Array[Texture2D] = []
## Color con el que se tiñe el sprite al llegar al daño máximo.
@export var color_destruido : Color = Color(0.25, 0.25, 0.25)

func actualizar_sprite(dano_actual: float, dano_maximo: float) -> void:
	var sprite : Sprite2D = get_parent().get_node("Sprite2D")
	var proporcion : float = clampf(dano_actual / dano_maximo, 0.0, 1.0)
	# Elegir el sprite de la lista según el porcentaje de daño.
	if not sprites_dano.is_empty():
		var indice : int = mini(int(proporcion * sprites_dano.size()), sprites_dano.size() - 1)
		if sprites_dano[indice] != null:
			sprite.texture = sprites_dano[indice]
	# Refuerzo visual: tinte progresivamente más oscuro.
	sprite.modulate = Color.WHITE.lerp(color_destruido, proporcion)
