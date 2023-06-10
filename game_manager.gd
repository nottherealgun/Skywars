extends Node

var money = 100
@onready var cam = get_node("/root/Main/MainCam") as Camera2D
var cam_follow_target = Vector2.ZERO
var boss_encountered = false

var enemies_killed = 0
var rooms_cleared = 0
var levels_cleared = 0
var sec_elapsed = 0
var min_elapsed = 0
var hr_elapsed = 0
var bosses_vanquished = 0

func _game_start():
	if !Global.is_connected("enemy_killed",entity_killed):
		Global.connect("enemy_killed",entity_killed)
	
	for n in Global.Main.get_children():
		if n.is_in_group("player"):
			if not n in Global.active_players:
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
	
	rooms_cleared = 0
	
	for r in Global.uncleared_rooms_arr:
		if r[1].is_in_group("special"):
			Global.uncleared_rooms_arr.erase(r)
			
	for r in Global.gen_maps:
		var cleared = true
		if r[0].is_in_group("special"):
			continue
		
		while null in r[1].get_meta("entities"):
			r[1].get_meta("entities").erase(null)
		
		for e in r[1].get_meta("entities"):
			if !is_instance_valid(e):
				continue
			if is_nan(e.position.x):
				Global.kill(e)
				continue
			if e.is_in_group("enemy"):
				cleared = false
				break
				
		if cleared:
			rooms_cleared += 1

	if sec_elapsed >= 60:
		sec_elapsed = 0
		min_elapsed += 1
	if min_elapsed >= 60:
		min_elapsed = 0
		hr_elapsed += 1
	
	var closest = null
	var dist = INF
	if Global.active_players.is_empty() == false and Global.current_room:
		var p = Global.active_players[0] as Player
		if p:
			while null in Global.active_entities:
				Global.active_entities.erase(null)
			var temp = Global.active_entities.duplicate()
			for e in temp:
				if !is_instance_valid(e) or !e:
					Global.active_entities.erase(e)
			for e in Global.active_entities:
				if e.is_in_group("enemy") == false or !e:
					continue
				if e.position.distance_to(p.position) < dist:
					dist = e.position.distance_to(p.position)
					closest = e
			if closest and Global.current_room.has_meta("entities"):
				Global.Dev.text = closest.name+", "+str(dist)+", "+str(len(Global.current_room.get_meta("entities")))
		
#		dev_vis()

var dev = []

func dev_vis():
	for d in dev:
		dev.erase(d)
		d.queue_free()
		
	for e in Global.current_room.get_meta("entities"):
		if !e:
			Global.current_room.get_meta("entities").erase(e)

	for e in Global.active_entities:
		if !e or !is_instance_of(e,Enemy):
#			Global.current_room.get_meta("entities").erase(e)
			continue
		var new = Line2D.new()
		new.default_color = Color.DARK_RED
		new.add_point(e.position)
		new.add_point(Global.active_players[0].position)
		dev.append(new)
		Global.Main.add_child(new)
	
	if len(Global.current_room.get_meta("entities")) == 1:
#		Global.current_room.get_meta("entities")[0].position = Global.active_players[0].position
#		Global.Cam.reset_smoothing()
#		Global.active_players[0].position = Global.current_room.get_meta("entities")[0].position
		for e in Global.current_room.get_meta("entities"):
			if is_instance_valid(e):
				var whatisthis = e
				var dist = e.position.distance_to(Global.active_players[0].position)
				print(dist, e.position)
		
func add_money(amnt:int):
#	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
#	tween.tween_property(self,"money",money+amnt,0.6)
	money += amnt

func player_killed(player):
	for p in Global.active_players:
		if p.fainted == false:
			return
	$Timer.paused = true
	Global.Scoreboard.display(levels_cleared,rooms_cleared,enemies_killed,bosses_vanquished,{"hrs":hr_elapsed,"min":min_elapsed,"sec":sec_elapsed})
	await Global.Scoreboard.reviewed
#	Global.sync_map(Global.current_map_uninit,Global.current_map_boss)
	Global.build_lobby()
	sec_elapsed = 0

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
	tween.tween_property(cam,"position",boss.position,3.0).from(boss.position+Vector2(0,1000))
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*2.5,1.0).from(Vector2(2,2)).set_trans(Tween.TRANS_ELASTIC)
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*3,6.0).from(Vector2(2.5,2.5)).set_trans(Tween.TRANS_LINEAR)
#	tween.chain().tween_property(cam,"zoom",Vector2.ONE*2,0.5).from(Vector2(4,4)).set_delay(2.0)
	
	await boss.started
	boss_encountered = false

func _on_timer_timeout():
	sec_elapsed += 1
