extends Node

@onready var cam = get_node("/root/Main/MainCam")
var cam_follow_target = Vector2.ZERO
var active_players = []

func _ready():
	for n in Global.Main.get_children():
		if n.is_in_group("player"):
			active_players.append(n)

func _process(delta):
	var vec := Vector2.ZERO
	for p in active_players:
		vec += p.position
	vec/=active_players.size()
	cam_follow_target = vec
	cam.position = cam_follow_target
	Global.Dev.text = str(Global.Main.get_node("Player").health)
