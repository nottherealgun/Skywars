extends Node

var money = 100
@onready var cam = get_node("/root/Main/MainCam") as Camera2D
var cam_follow_target = Vector2.ZERO
var boss_encountered = false

func _game_start():
	if !Global.is_connected("enemy_killed",entity_killed):
		Global.connect("enemy_killed",entity_killed)
	
	for n in Global.Main.get_children():
		if n.is_in_group("player"):
			Global.active_players.append(n)
			n.connect("kills_player",player_killed)
	
	Global.Inventory.start()
	
	cam.position = Global.active_players[0].position
	cam.reset_smoothing()
	
func _process(_delta):
	var a = []
	for m in Global.Main.get_children():
		if m is TileMap:
			a.append(m)
	
	var vec := Vector2.ZERO
	for p in Global.active_players:
		vec += p.position
	vec/=Global.active_players.size()
	cam_follow_target = vec
	if !boss_encountered:
		cam.position = cam_follow_target
	
	get_node("/root/Main/GUI/PlayerStats/MoneyGUI/MoneyLabel").text = str(int(money))
#	Global.Dev.text = str(Global.current_room,"\n\n",Global.active_rooms,"\n\n",Global.active_rooms.find(Global.current_room))
#	Global.Dev.text = str(Global.gen_maps)
	
func add_money(amnt:int):
#	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
#	tween.tween_property(self,"money",money+amnt,0.6)
	money += amnt

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
		if !is_instance_valid(e):
			Global.active_entities.erase(e)
		elif e.is_in_group("enemy"):
			active_enemies.append(e)
	
	if active_enemies.size() == 0:
		if entity.is_in_group("enemy"):
			Global.music_play("lobby")

func boss_encounter(boss:Node):
	boss_encountered = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(cam,"position",boss.position,7.0).from(boss.position+Vector2(0,1000))
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*2.5,1.0).from(Vector2(2,2)).set_trans(Tween.TRANS_ELASTIC)
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*3,6.0).from(Vector2(2.5,2.5)).set_trans(Tween.TRANS_LINEAR)
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*2,0.5).from(Vector2(4,4)).set_delay(2.0)
	
	await boss.started
	boss_encountered = false
