class_name DamageVisualConfig
extends Resource
## Configuración visual del daño.

## Sprites de menor a mayor desgaste (p. ej. leve, medio, destruido).
## Si está vacío, solo se oscurece el sprite original.
@export var sprites_dano: Array[Texture2D] = []
## Color con el que se tiñe el sprite al llegar al daño máximo.
@export var color_destruido: Color = Color(0.25, 0.25, 0.25)
