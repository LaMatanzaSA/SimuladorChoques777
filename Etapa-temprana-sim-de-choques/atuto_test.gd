class_name Personaje
extends CharacterBody2D
@export var fuerza_empuje = 50
@export var gravity = 300
@export var max_speed : float = 400.0
@export var accel : float = 800.0
@export var friction : float = 600.0
var target_rotation : float = 0.0
var rotation_speed : float = 10.0
var push_speed : float = max_speed * 0.6
var speed : float = 0.0
var is_pushing : bool = false

func _physics_process(delta):
	
	# gravedad
	if not is_on_floor():
		velocity.y = velocity.y + gravity * delta

	#movimiento_H
	var max_speed = push_speed if is_pushing else max_speed
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction !=0:
		speed = move_toward(speed, direction * max_speed, accel * delta)
	else:
		speed = move_toward(speed, 0.0, friction * delta)
	velocity.x = speed
	move_and_slide()
	
	#rotación según suelo
	if is_on_floor():
		var floor_normal = get_floor_normal()
		target_rotation = floor_normal.angle() + (PI/2)
	elif velocity.y < -50: 
		target_rotation = 0.0
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	#colisión con objetos
	is_pushing = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			velocity.y = 0
			is_pushing = true
			var push_dir = Vector2(sign(speed), 0)
			push_dir.y = 0 
			if push_dir.x != 0:
				collider.apply_central_impulse(push_dir * fuerza_empuje)
