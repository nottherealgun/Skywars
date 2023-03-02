extends Node

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE):
		Global.spawn_enemy("enemy",Vector2.ZERO)
