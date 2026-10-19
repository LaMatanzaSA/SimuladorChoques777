## ÚNICA responsabilidad: detectar que el vehículo chocó contra un obstáculo
## y avisar con qué fuerza. No calcula daño ni toca sprites/físicas.
## Va como hijo del vehículo (Personaje), es un Area2D que cubre su carrocería.
## Su señal nativa `body_entered` se conecta a `_on_body_entered` desde la escena.
class_name CollisionDetector
extends Area2D

## Se emite al detectar un choque válido. `fuerza` = velocidad horizontal al impactar.
signal impacto_detectado(fuerza: float)

## Grupo que identifica a los cuerpos que cuentan como obstáculo.
@export var grupo_obstaculo : StringName = &"obstaculo"
## Por debajo de esta velocidad el roce no cuenta como choque.
@export var velocidad_minima : float = 60.0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(grupo_obstaculo):
		return
	# La fuerza del impacto es la velocidad actual del vehículo (padre).
	var fuerza : float = absf((get_parent() as Personaje).speed)
	if fuerza < velocidad_minima:
		return
	impacto_detectado.emit(fuerza)
