extends Node

@onready var cam = get_node("/root/Main/MainCam")
var cam_follow_target = Vector2.ZERO

func _process(delta):
	cam_follow_target = Global.Main.get_node("Player").position
	cam.position = cam_follow_target
	Global.Dev.text = str(Global.Main.get_node("Player").health)
