class_name VehiclePusher
extends Node
## ÚNICA responsabilidad: empujar los cuerpos con física que toca el vehículo.
## Es "empujable" todo objeto que ofrezca `apply_central_impulse` (duck typing).

## Devuelve true si había al menos un cuerpo empujable en contacto.
func empujar(cuerpos: Array[Object], sentido: float, fuerza: float) -> bool:
	var empujando: bool = false
	for cuerpo: Object in cuerpos:
		if not is_instance_valid(cuerpo) or not cuerpo.has_method(&"apply_central_impulse"):
			continue
		empujando = true
		if sentido != 0.0:
			cuerpo.call(&"apply_central_impulse", Vector2(sentido, 0.0) * fuerza)
	return empujando
