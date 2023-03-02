extends Node

@onready var player = get_node("/root/Main/Player")

@export var max_health = 100
var health = max_health
@export var speed = 3
var move_vec := Vector2.ZERO
var aim_vec := Vector2.ZERO

func _physics_process(delta):
	_input_update()
	_move_update(delta)
	var sprite = player.get_node("Sprite")
	if move_vec != Vector2.ZERO:
		sprite.animation = "run"
		if move_vec.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		sprite.animation = "idle"

func _input_update():
	aim_vec = Vector2(Input.get_action_strength("p1_right2") - Input.get_action_strength("p1_left2"),
	Input.get_action_strength("p1_down2") - Input.get_action_strength("p1_up2")).normalized()
	player.get_node("Arrow").rotation = player.get_node("Arrow").position.angle_to_point(aim_vec)
	if Input.is_action_just_pressed("p1_primary"):
			if aim_vec != Vector2.ZERO:
				shoot()
				
func _move_update(delta):
	move_vec = Vector2.ZERO
	if Input.is_action_pressed("p1_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("p1_down"):
		move_vec.y += 1
	if Input.is_action_pressed("p1_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("p1_right"):
		move_vec.x += 1
	player.position += move_vec.normalized()*delta*speed*100
	player.position.x = clamp(player.position.x, 0, Global.Map.get_used_rect().size.x*128)
	player.position.y = clamp(player.position.y, 0, Global.Map.get_used_rect().size.y*128)

func shoot():
	Global.spawn_projectile("projectile",player.position,aim_vec)
