extends Node

@onready var cam = get_node("/root/Main/MainCam")
var cam_follow_target = Vector2.ZERO

@onready var testmap = load("res://rooms/adit_building_1.tscn").instantiate()
func _ready():
	for n in Global.Main.get_children():
		if n.is_in_group("player"):
			Global.active_players.append(n)

func _process(delta):
	var vec := Vector2.ZERO
	for p in Global.active_players:
		vec += p.position
	vec/=Global.active_players.size()
	cam_follow_target = vec
	cam.position = cam_follow_target
	Global.Dev.text = str(Global.active_players[0].transporting)
