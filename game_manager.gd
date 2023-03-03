extends Node

func _process(delta):
	Global.Dev.text = "P_health: "+str(PlayerManager.health)
	Global.Dev.text += "\nRoom ID: "+str(LevelManager.rooms.find(LevelManager.current_room))
