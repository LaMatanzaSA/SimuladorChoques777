# Dentro del _physics_process(delta) de tu Personaje.gd:
if is_instance_valid(nodo_parallax):
	nodo_parallax.scroll_base_offset.x -= speed * delta * 0.2 # 0.2 es el factor de profundidad
