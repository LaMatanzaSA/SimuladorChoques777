class_name VehiclePusher
extends Node
## ÚNICA responsabilidad: empujar los cuerpos con física que toca el vehículo.
## Es "empujable" todo objeto que ofrezca `apply_central_impulse` (duck typing).
## Lee por sí mismo los contactos del último `move_and_slide()` del cuerpo.

## Devuelve true si había al menos un cuerpo empujable en contacto.
func empujar(cuerpo: CharacterBody2D, sentido: float, fuerza: float) -> bool:
	var empujando: bool = false
	for i: int in cuerpo.get_slide_collision_count():
		var contacto: Object = cuerpo.get_slide_collision(i).get_collider()
		if not is_instance_valid(contacto) or not contacto.has_method(&"apply_central_impulse"):
			continue
		empujando = true
		if sentido != 0.0:
			contacto.call(&"apply_central_impulse", Vector2(sentido, 0.0) * fuerza)
	return empujando
