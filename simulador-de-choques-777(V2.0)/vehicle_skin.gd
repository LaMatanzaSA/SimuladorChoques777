class_name VehicleSkin
extends Node
## ÚNICA responsabilidad: poner en el sprite del vehículo la textura del auto elegido.
## Se crea sola desde `Personaje` (vía `VehicleWiring`) si la escena no la trae.

@export var _sprite: Sprite2D

func _ready() -> void:
	if not is_instance_valid(_sprite):
		_sprite = _buscar_sprite()
	aplicar(GameManager.auto_seleccionado)

## Aplica la textura de `ruta` si existe; si no, deja la que ya tenía el sprite.
func aplicar(ruta: String) -> void:
	if not is_instance_valid(_sprite) or not ResourceLoader.exists(ruta):
		return
	var textura: Texture2D = load(ruta) as Texture2D
	if textura != null:
		_sprite.texture = textura

func _buscar_sprite() -> Sprite2D:
	var padre: Node = get_parent()
	if padre == null:
		return null
	for hijo: Node in padre.get_children():
		if hijo is Sprite2D:
			return hijo as Sprite2D
	return null
