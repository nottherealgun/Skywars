extends Node

func _process(delta):
	Global.Dev.text = "P_health: "+str(PlayerManager.health)
	Global.Dev.text = "\n"+str(Global.MAP_RECT/64)
