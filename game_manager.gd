extends Node

@onready var cam = get_node("/root/Main/MainCam")
var cam_follow_target = Vector2.ZERO
var boss_encountered = false

func _ready():
	Global.connect("enemy_killed",entity_killed)
	
	for n in Global.Main.get_children():
		if n.is_in_group("player"):
			Global.active_players.append(n)
			n.connect("player_killed",player_killed)
	
	Global.Inventory.start()
	
func _process(_delta):
	var vec := Vector2.ZERO
	for p in Global.active_players:
		vec += p.position
	vec/=Global.active_players.size()
	cam_follow_target = vec
	if !boss_encountered:
		cam.position = cam_follow_target
#	Global.Dev.text = str(Global.active_players[0].transporting)

func player_killed(player):
	for p in Global.active_players:
		if p.fainted == false:
			break
		else:
			if p == Global.active_players.back():
				Global.sync_map(Global.current_map_uninit,Global.current_map_boss)

func entity_killed(entity):
	var active_enemies = []
	for e in Global.active_entities:
		if e.is_in_group("enemy"):
			active_enemies.append(e)
	
	if active_enemies.size() == 0:
		if entity.is_in_group("enemy"):
			Global.music_play("lobby")

func boss_encounter(boss:Node):
	boss_encountered = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(cam,"position",boss.position,10).from(cam_follow_target)
#	tween.chain().tween_property(cam,"position",cam_follow_target,5)
	await boss.started
	boss_encountered = false
