class_name DamageVisualConfig
extends Resource
## Configuración visual del daño y la lógica para traducir daño en aspecto.

## Sprites de menor a mayor desgaste (osea, bien,maso,destruido y así).
## Si está vacío, solo se oscurece el sprite original.
@export var _sprites_dano: Array[Texture2D] = []
## Color con el que se tiñe el sprite al llegar al daño máximo.
@export var _color_destruido: Color = Color(0.25, 0.25, 0.25)

## Textura que corresponde a una proporción de daño [0, 1]; null si no hay sprites configurados.
func textura_para(proporcion: float) -> Texture2D:
	if _sprites_dano.is_empty():
		return null
	var indice: int = mini(int(proporcion * _sprites_dano.size()), _sprites_dano.size() - 1)
	return _sprites_dano[indice]

## Color de teñido que corresponde a una proporción de daño [0, 1].
func color_para(proporcion: float) -> Color:
	return Color.WHITE.lerp(_color_destruido, proporcion)
