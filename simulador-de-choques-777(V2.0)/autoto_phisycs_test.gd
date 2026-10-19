class_name auto_phisycs
extends CharacterBody2D

@export var umbral_choque : float = 150.0 
@export var resistencia_metal : float = 0.5 
@export var radio_deformacion : float = 40.0 
@onready var visual_poly = $Polygon2D
@onready var collision_poly = $CollisionPolygon2D

func deformar_chasis(punto_impacto: Vector2, direccion: Vector2, fuerza: float):
	var current_poly = visual_poly.polygon
	var deformado = false
	
	for i in range(current_poly.size()):
		var vertice = current_poly[i]
		var distancia = vertice.distance_to(punto_impacto)
		
		if distancia < radio_deformacion:
			var factor_cercania = 1.0 - (distancia / radio_deformacion)
			# Limitamos el desplazamiento para que los vértices no se solapen
			var empuje = min(fuerza * factor_cercania, 12.0)
			
			current_poly[i] += direccion * empuje
			deformado = true
			
	if deformado:
		# 1. La parte visual se actualiza al instante
		visual_poly.polygon = current_poly
		
		# 2. La física se actualiza de forma diferida para evitar romper el motor de físicas
		collision_poly.set_deferred("polygon", current_poly)
