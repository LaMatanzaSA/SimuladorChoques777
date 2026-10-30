class_name VehiclePusher
extends Node
## ÚNICA responsabilidad: empujar los RigidBody2D contra los que se choca el vehículo.

## Devuelve true si está empujando algún RigidBody2D.
func empujar(vehiculo: CharacterBody2D, velocidad: float, fuerza: float) -> bool:
	var empujando: bool = false
	for i: int in vehiculo.get_slide_collision_count():
		var colision: KinematicCollision2D = vehiculo.get_slide_collision(i)
		var cuerpo: Object = colision.get_collider()
		if cuerpo is RigidBody2D:
			vehiculo.velocity.y = 0.0
			empujando = true
			var direccion := Vector2(signf(velocidad), 0.0)
			if direccion.x != 0.0:
				(cuerpo as RigidBody2D).apply_central_impulse(direccion * fuerza)
	return empujando
