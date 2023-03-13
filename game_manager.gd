extends Node

@onready var cam = get_node("/root/Main/MainCam")
var cam_follow_target = Vector2.ZERO

func _ready():
	Global.connect("enemy_killed",entity_killed)
	
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
	
	for p in Global.active_players:
		if p.fainted == false:
			break
		else:
			if p == Global.active_players.back():
				Global.sync_map(LevelManager.testmap)

func entity_killed(entity):
	var active_enemies = []
	for e in Global.active_entities:
		if e.is_in_group("enemy"):
			active_enemies.append(e)
	
	if active_enemies.size() == 0:
		if entity.is_in_group("enemy"):
			print("ROOM CLEARED.")
			Global.music_play("default")
