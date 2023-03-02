extends Node

@onready var player = get_node("/root/Main/Player")

@export var max_health = 100
var health = max_health
@export var speed = 3
var move_vec := Vector2.ZERO

func _process(delta):
	_move_update(delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("primary"):
			shoot()

func _move_update(delta):
	move_vec = Vector2.ZERO
	if Input.is_action_pressed("up"):
		move_vec.y -= 1
	if Input.is_action_pressed("down"):
		move_vec.y += 1
	if Input.is_action_pressed("left"):
		move_vec.x -= 1
	if Input.is_action_pressed("right"):
		move_vec.x += 1
	
	player.position += move_vec.normalized()*delta*speed*100
	player.position.x = clamp(player.position.x, 0, Global.Map.get_used_rect().size.x*128)
	player.position.y = clamp(player.position.y, 0, Global.Map.get_used_rect().size.y*128)

func shoot():
	Global.spawn_projectile("projectile",player.position,player.position.direction_to(Global.Main.get_global_mouse_position()))
