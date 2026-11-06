extends ParallaxBackground

@onready var sprite_fondo: Sprite2D = $ParallaxLayer/Mundo1

func _ready() -> void:
	_aplicar_textura_fondo()

func _aplicar_textura_fondo() -> void:
	if ResourceLoader.exists(GameManager.mapa_seleccionado):
		var nueva_textura = load(GameManager.mapa_seleccionado) as Texture2D
		if is_instance_valid(sprite_fondo) and nueva_textura != null:
			sprite_fondo.texture = nueva_textura
