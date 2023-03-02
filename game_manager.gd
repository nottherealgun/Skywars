extends Node

func _process(delta):
	Global.Dev.text = "P_health: "+str(PlayerManager.health)
	if Input.is_key_pressed(KEY_SPACE):
		Global.spawn_enemy("enemy",Vector2.ZERO)
