extends Node
signal enemy_killed(enemy)

# Resources

@onready var Main := get_node("/root/Main") 							as Node2D
@onready var Map := get_node("/root/Main/Map") 							as TileMap
@onready var GUI := get_node("/root/Main/GUI") 							as CanvasLayer
@onready var Dev := get_node("/root/Main/GUI/Dev") 						as Label
@onready var Music := get_node("/root/Main/Music") 						as AudioStreamPlayer
@onready var Bossbar := get_node("/root/Main/GUI/BossBar") 				as Control
@onready var PauseMenu := get_node("/root/Main/GUI/PauseMenu")			as Control
@onready var Cam := get_node("/root/Main/MainCam") 						as Camera2D
@onready var Inventory := get_node("/root/Main/GUI/PlayerInventory") 	as Control

@onready var MAP_RECT : Vector2 = Map.get_used_rect().size*128

var current_map_uninit
var current_map
var current_map_boss

var cached_rooms = []
var active_players = []

# Entities

var active_entities = []

func spawn_in(entity):
	active_entities.append(entity)
	Main.add_child(entity)
	return entity

func spawn_projectile(shooter:Node,proj_name:String,pos:Vector2,dir:Vector2,player_bullet=false,dmg:=10):
	var new_proj = load("res://projectiles/"+proj_name+".tscn").instantiate()
	new_proj.shooter = shooter
	new_proj.position = pos
	new_proj.direction = dir
	new_proj.player_bullet = player_bullet
	new_proj.damage = dmg
	active_entities.append(new_proj)
	Main.add_child(new_proj)
	return new_proj

func spawn_enemy(enemy_name:String,pos:Vector2):
	var new_enemy = load("res://enemies/"+enemy_name+".tscn").instantiate()
	new_enemy.position = pos
	active_entities.append(new_enemy)
	Main.add_child(new_enemy)
	return new_enemy

func spawn_from_ability(entity:String,pos:Vector2,user:Node):
	var new_entity = load("res://abilities/"+entity+".tscn").instantiate()
	new_entity.position = pos
	new_entity.master = user
	user.minions.append(new_entity)
	active_entities.append(new_entity)
	Main.add_child(new_entity)
	return new_entity

func spawn_manual(entity_path:String,pos:Vector2):
	var new_entity = load(entity_path).instantiate()
	new_entity.position = pos
	active_entities.append(new_entity)
	Main.add_child(new_entity)
	return new_entity

func kill(entity:Node,immediate=false):
	if is_instance_valid(entity) and entity in active_entities:
		emit_signal("enemy_killed",entity)
		active_entities.erase(entity)
		var tween = create_tween()
		if immediate == false:
			tween.tween_property(entity,"scale",Vector2.ZERO,0.2)
			tween.chain().tween_callback(entity.queue_free)
			
		if entity.is_in_group("enemy"):
			tween.parallel().tween_callback(emit_death_indicator.bind(entity.position))
			if entity.health <= 0:
				GameManager.add_money(entity.points)
			
		elif entity.is_in_group("projectile"):
			entity.current_speed = 0
#		entity.queue_free()

func kill_all(exceptions:=[]):
	while not active_entities.is_empty():
		var released = false
		var e = active_entities.front()
		if is_instance_valid(e):
			if exceptions != []:
				for x in exceptions:
					if e.is_in_group(x):
						released = true
			if !released:
				kill(e)
				continue
				
		if exceptions != []:
			break
# Bosses

func spawn_boss(type:String,pos:Vector2):
	var new_boss = load("res://enemies/bosses/"+type+".tscn").instantiate().duplicate()
	new_boss.position = pos
	active_entities.append(new_boss)
	Main.add_child(new_boss)
	Bossbar.set_boss(new_boss)
	return new_boss

# Doors

func get_map_perimeter():
	var perimeter = Map.get_used_rect().size.x*2
	perimeter += Map.get_used_rect().size.y*2
	return perimeter

var active_doors = []

func get_door_pos(size:Vector2i):
	var door_pos : Vector2
	var rand_pos = Vector2i(-1,-1)
	var rand_side = ["left","top","right","bottom"][randi()%4]
	var flip = true
	match rand_side:
		"left":
			rand_pos.y = (randi()%size.y)
			flip=false
		"right":
			rand_pos.x = size.x
			rand_pos.y = (randi()%size.y)
			flip=false
		"top":
			rand_pos.x = (randi()%size.x)
		"bottom":
			rand_pos.y = size.y
			rand_pos.x = (randi()%size.x)
		
	door_pos = Map.map_to_local(rand_pos)
	door_pos = Map.to_global(door_pos)
		
	return [door_pos,flip,rand_side]

func new_door(room_size=Map.get_used_rect().size):
	var new_door_instance = load("res://objects/door.tscn").instantiate()
	var new = get_door_pos(room_size)
	new_door_instance.position = new[0]
	new_door_instance.horizontal = new[1]
	new_door_instance.side = new[2]
	return new_door_instance

func install_door(node:Node):
	active_doors.append(node)
	Main.add_child(node)

var map_spawnpoint : Vector2

var rooms = [
	{"file":"lobby.tscn","name":"Aditayathorn Lobby"},
	{"file":"test_map.tscn","name":"Test Map"},
	{"file":"adit_treasure.tscn","name":"Treasure Room"},
	{"file":"adit_single_1.tscn","name":"Single Room 1"},
	{"file":"adit_single_2.tscn","name":"Single Room 2"},
	{"file":"adit_double_1.tscn","name":"Double Room 1"},
	{"file":"adit_t_1.tscn","name":"T-shaped Room 1"},
]

const tips = [
	"Be careful of the ICT.",
	"If you try really hard, you \"might\" be able to get an A.",
	"Darwin said that \"Creative Technology\" is a weak name for our major.",
	"Fun fact: This game\'s dev team has a podcast.",	
	"Thank you Mr. Orion for making the game's music!",
	"Thank you Mr. Darwin for making the game's sprites!",
	"Thank you Mr. Ice for managing our project!",
	"This is solid advice. Do not forget to do your EC outline.",
	"Creeper. Aww man.",
	"Co co co co co co co co nut.",
	"I'm never gonna give you up, I'm never gonna let you down.",
	"As a dev, I'm just putting random stuff here.",
	"One of the inspirations for this game is a video game called \"Moonlighter\".",
	"All of the music courses in ICCT has a single credit except Music Appreciation.",
	"BOY. YOU'RE NOT.. READY.",
	"Woah. Oh.. mai god.",
	"Do not take Voldemort for EC1.",
	"Do not take Analiza for EC3.",
	"It's not a staff who's managing the ICT servers, it's actually a mini gorilla.",
	"Join ICCT, we have cookies here. Accept them.",
	"This game's dev team has two cursed beasts.",
	"Please take Art History as fast as possible.",
	"Aj. Pisit may or may not have a Zoog plushie on his bed.",
	"Aj. Pilailuck has a PhD degree.",
	"Do not try to argue with Orion about coffee.",
	"EmOtIoNaL DaMaGe.",
	"Aj. Nippon loves to cancel classes.",
	"The national animal of MUIC is a monitor lizard.",
	"Ice's glasses doesn't have lens.",
	"SproutDude is actually not a plant.",
	"If you like Computing Tech. We are not friends.",
	"Poom is a SIGMA MALE.",
	"Try Dennis' game: Archplan!",
	"MUIC printers hates dark palettes.",
	"One of Aj Dale's favorite places is The Louvre.",
	"That's a PAEW PAEW PAEW moment.",
	"This game's name used to be \"Creative Clash\".",
	"This project all started with two freshmen in a programming class.",
	"Aj. Nik is able to bully you with his critical criticism.",
	"Ice is actually Tadano-kun in disguise.",
	"Shame on you. ComEn simpletons.",
	"CDP is our cousin.",
	"None of this game's tips are helpful.",
	"Your culturedness level depends on how much anime you watch.",
	"A stands for Average, B stands for STOOPID.",
	"Co-working Space has air conditioning.",
	"FreshMe is overpriced.",
	"The Walker's Special is actually tea. Don't tell Orion.",
	"Potatoes are vegetables.",
	"Dennis has a bird nest on his balcony.",
	"Plu is a natural enemy of CT. (Because he is in CDP)",
	"I walked uphills both ways, on one foot. The other foot is starting a business.",
	"Wong Jick is a man of focus, commitment, and sheer f-cking will.",
	"WASD to walk.",
	"Aj. Nik used to be a student at MUIC.",
	"Bro is here.",
]

const items = [
	{ #0
		"name":"NotTheRealGun",
		"type":"trinket",
		"pic":"notTheRealGun.png",
		"desc":"We don’t support school shootings. So, this is just a NERF gun.",
		"stats":"+5% Critical Chance (x2 damage on crit)",
	},
	{
		"name":"Amulet of Dood",
		"type":"trinket",
		"pic":"amuletOfDood.png",
		"desc":"A periapt forged by mother nature herself.",
		"stats":"+10% Minion's Damage or Heal",
	},
	{
		"name":"The Ice of Ice",
		"type":"trinket",
		"pic":"icyboiIce.png",
		"desc":"This ice is Ice’s ice which belongs to Ice. Cooler than Ice himself.",
		"stats":"+10% Slow on hit",
	},
	{
		"name":"Walker's Special",
		"type":"trinket",
		"pic":"walkerSpecial.png",
		"desc":"A secret recipe passed down from the first ancestor of Walker’s family.",
		"stats":"+10% Attack Speed",
	},
	{ 
		"name":"Worrier Froge",
		"type":"trinket",
		"pic":"froge.png",
		"desc":"The most versatile emoji on Earth. When you look closely, it looks like Ken.",
		"stats":"+30% Dashing Distance",
	},
	{ #5
		"name":"Ken's Gachapon",
		"type":"trinket",
		"pic":"",
		"desc":"Pure sodium chloride.",
		"stats":"",
	},
	{
		"name":"Bro Was Here",
		"type":"trinket",
		"pic":"",
		"desc":"I hate it here.",
		"stats":"",
	},
	{
		"name":"Kouprey's Horn",
		"type":"trinket",
		"pic":"koupreyHorn.png",
		"desc":"A forbidden ingredient for aphrodisiac.",
		"stats":"+10% Damage",
	},
	{
		"name":"Moss",
		"type":"trinket",
		"pic":"",
		"desc":"A sacred beast tamed by Mr.Will.",
		"stats":"",
	},
	{
		"name":"Archplan Copy",
		"type":"trinket",
		"pic":"",
		"desc":"A copy of Archplan; A game made by Dennis.",
		"stats":"",
	},
	{ #10
		"name":"James’s Hoodie",
		"type":"trinket",
		"pic":"",
		"desc":"He was there. He was always there.",
		"stats":"",
	},
	{
		"name":"AJ's Basketball",
		"type":"trinket",
		"pic":"",
		"desc":"This ball’s owner has the level of extrovertedness equivalent to a whole NFL match.",
		"stats":"",
	},
	{
		"name":"Konit's Brick",
		"type":"trinket",
		"pic":"konit_brick.png",
		"desc":"Bricked.",
		"stats":"+15% Damage Reduction",
	},
	{
		"name":"Tim's Shakes",
		"type":"trinket",
		"pic":"",
		"desc":"We don't know what it is but it’s Tim’s.",
		"stats":"",
	},
	{
		"name":"Advisor's Approval",
		"type":"trinket",
		"pic":"",
		"desc":"Online. Offline. Online again, Offline. Oh, finally replied.",
		"stats":"",
	},
	{ #15
		"name":"Salmon Nigiri",
		"type":"consumable",
		"pic":"salmonNigiri.png",
		"desc":"It’s actually trout.",
		"stats":"+ 20% Heal\n+ 2 Brain cells",
		"cost":10,
		"scale_factor":0.75,
	},
	{
		"name":"Tonkatsu Curry",
		"type":"consumable",
		"pic":"curry.png",
		"desc":"If you’re planning to get MUIC’s curry, just don’t.",
		"stats":"+ Fully recovers your health",
		"cost":1,
		"scale_factor":1,
	},
	{
		"name":"Khao Mun Gai",
		"type":"consumable",
		"pic":"chickrice.png",
		"desc":"A delicacy from Hainan.",
		"stats":"+ Recovers 75% of your health",
		"cost":1,
		"scale_factor":1,
	},
	{
		"name":"Ohm's Gyoza",
		"type":"consumable",
		"pic":"gyoza.png",
		"desc":"Available at Athit’s Gyoza.",
		"stats":"+ Recovers 50% of your health",
		"cost":1,
		"scale_factor":0.75,
	},
	{
		"name":"Dispensed Water",
		"type":"consumable",
		"pic":"dispensed_water.png",
		"desc":"4oz. of water.",
		"stats":"+ Refreshes the brain cell bar\n+ Removes debuffs",
		"cost":1,
		"scale_factor":0.6,
	},
	{ #20
		"name":"The Walker Espress",
		"type":"consumable",
		"pic":"walker_espress.png",
		"desc":"An Orion-certified beverage. As he’d said before, “Pure coffee juice.”",
		"stats":"+ Insane Movement Speed\n+ Drains your entire brain cell bar",
		"cost":1,
		"scale_factor":0.6,
	},
	{
		"name":"American-O",
		"type":"consumable",
		"pic":"americano.png",
		"desc":"A bit of coffee and tons of water. A truly watered-down drink.",
		"stats":"+ Doubles the amount of projectiles\n+ Disables dash mechanic",
		"cost":1,
		"scale_factor":0.75,
	},
	{
		"name":"Cap's Mustache",
		"type":"consumable",
		"pic":"cap_mustache.png",
		"desc":"YAHOOO. It’s-a me, Cappuccino.",
		"stats":"+ Doubles brain cell recharge rate\n+ 1.5x brain cell consumption rate",
		"cost":1,
		"scale_factor":0.6,
	},
	{
		"name":"Shot O' Latte",
		"type":"consumable",
		"pic":"shot_o_latte.png",
		"desc":"Chotto latte kudasai, oniichan~",
		"stats":"+ Improves attack speed\n+ Decreases movement speed",
		"cost":1,
		"scale_factor":0.6,
	},
	{
		"name":"De Moch Crazy",
		"type":"consumable",
		"pic":"de_moch_crazy.png",
		"desc":"Je suis fou de chocolat cafe!",
		"stats":"+ Every 10th bullet's damage is increased tenfold\n+ Your controls are reversed",
		"cost":1,
		"scale_factor":0.6,
	},
	{ #25
		"name":"Dirty Bean Juice",
		"type":"consumable",
		"pic":"dirty_bean_juice.png",
		"desc":"No bacteria included, only lactobacillus.",
		"stats":"+ Increases defense by 10%\n+ Killed enemies drop more coins",
		"cost":1,
		"scale_factor":0.6,
	},
]

# Levels
func sync_map(map:Node2D,boss:=""):
	randomize()
	# Prepare spawnpoints
	var target_map = map.duplicate()
	current_map_uninit = map
	current_map = target_map
	current_map_boss = boss
	
	var spawn_poses = []
	map_spawnpoint = target_map.find_child("SpawningPoint").position
	
	for p in active_players:
		var radius = 25
		spawn_poses.append(map_spawnpoint+Vector2(randi()%radius,randi()%radius))
		p.transporting = true
		p.y_sort_enabled = false

	# Entry Transition
	var transition_screen = GUI.get_node("Transition")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	transition_screen.get_node("Tips").text = "[center][wave amp=25 freq=10]\n"+"Tip: "+str(tips[randi()%tips.size()])
	tween.tween_property(transition_screen.material,"shader_parameter/progress",1.0,2).from(0.0)
	
	await tween.step_finished
	# Set level title name
	for r in rooms:
		if map.name == load("res://rooms/"+r["file"]).instantiate().name:
			GUI.get_node("Title").text = r["name"]
			break
#	GUI.get_node("Title").text = target_map.name.capitalize()
		
	# Clear old map tiles
	Map.clear()
	# Clear old entities
	LevelManager.clear_level()
	
	await get_tree().create_timer(3.0).timeout
	
	# Install map tiles
	var old_map = Map
	var new_map = target_map.get_node("Map")
	Map = new_map
	Main.remove_child(old_map)
	target_map.remove_child(new_map)
	Main.add_child(new_map)
	old_map.queue_free()
	
	MAP_RECT = Map.get_used_rect().size*128
	
	# Install map enemies
	for entity in target_map.get_children():
		if entity.get_class() in ["TileMap","Marker2D"]:
			continue
		target_map.remove_child(entity)
		active_entities.append(entity)
		Main.add_child(entity)
	
	if map.name == load("res://rooms/"+rooms[0].file).instantiate().name:
		if current_track != "lobby":
			music_play("lobby")
	else:
		if boss == "":
			if current_track != "combat":
				music_play("combat")
		else:
			match boss:
				"printerovski_3000":
					if current_track != "printerboss":
						music_play("printerboss")
	
	if boss != "":
		var new_boss = spawn_boss(boss,MAP_RECT/4)
		GameManager.boss_encounter(new_boss)
	
		# Set new player positions
	for p in active_players:
		if p.fainted:
			p.revive()
		p.position = spawn_poses[active_players.find(p)]
		p.transporting = false
		p.y_sort_enabled = true
		for m in p.minions:
			active_entities.append(m)
	
	# Exit Transition
	tween = create_tween()
	tween.tween_property(transition_screen.material,"shader_parameter/progress",0.0,1.5).from(1.0)
	tween.chain().tween_property(GUI.get_node("Title"),"modulate",Color.WHITE,1.0).from(Color.TRANSPARENT)
	tween.chain().tween_property(GUI.get_node("Title"),"modulate",Color.TRANSPARENT,1.0).from(Color.WHITE).set_delay(3.0)

func sync_room(map:Node,boss=""):
	randomize()
	# Prepare spawnpoints
	var target_map = map.duplicate()
	current_map_uninit = map
	current_map = target_map
	current_map_boss = boss
	var spawn_poses = []
	map_spawnpoint = target_map.find_child("SpawningPoint").position
	
	for p in active_players:
		var radius = 25
		spawn_poses.append(map_spawnpoint+Vector2(randi()%radius,randi()%radius))
		p.transporting = true
		p.y_sort_enabled = false

	# Set level title name
	for r in rooms:
		if map.name == load("res://rooms/"+r["file"]).instantiate().name:
			GUI.get_node("Title").text = r["name"]
			break
#	GUI.get_node("Title").text = target_map.name.capitalize()

	# Clear old map tiles
	Map.clear()
	# Clear old entities
	LevelManager.clear_level()
	
	# Install map tiles
	var old_map = Map
	var new_map = target_map.get_node("Map")
	Map = new_map
	Main.remove_child(old_map)
	target_map.remove_child(new_map)
	Main.add_child(new_map)
	old_map.queue_free()
	
	MAP_RECT = Map.get_used_rect().size*128
	
	# Install map enemies
	for entity in target_map.get_children():
		if entity.get_class() in ["TileMap","Marker2D"]:
			continue
		target_map.remove_child(entity)
		active_entities.append(entity)
		Main.add_child(entity)
	
	if map.name == load("res://rooms/"+rooms[0].file).instantiate().name:
		if current_track != "lobby":
			music_play("lobby")
	else:
		if current_track != "combat":
			music_play("combat")
	
	# Set new player positions
	for p in active_players:
		p.position = spawn_poses[active_players.find(p)]
		p.transporting = false
		p.y_sort_enabled = true
		if p.fainted:
			p.revive()
			for m in p.minions:
				active_entities.append(m)

func is_out_of_map(pos:Vector2) -> bool:
	var map_local_pos = Map.to_local(pos)
	var cell = Map.local_to_map(map_local_pos)
	var data = Map.get_cell_tile_data(0,cell)
	if data:
		return true
	else:
		return false

# Utility

func emit_indicator(amnt:float,pos:Vector2,p_bullet=false,heal:=false):
	var new_indicator = load("res://utility/damage_indicator.tscn").instantiate()
	new_indicator.position = pos
	new_indicator.amount = roundi(amnt)
	new_indicator.player_bullet = p_bullet
	new_indicator.heal = heal
	if heal:
		new_indicator.symbol = "+"
	Main.add_child.call_deferred(new_indicator)

func emit_death_indicator(pos:Vector2):
	var new_particle = load("res://utility/death_indicator.tscn").instantiate()
	new_particle.position = pos
	Main.add_child(new_particle)

func pick_by_percentage(ratios:Dictionary):
	# {"a":1,"b":2,"c":3}
	# sum = 6
	var keys = ratios.keys()
	var sum = 0
	var ranges = {}
	var range_start = 0
	for k in keys:
		sum += ratios[k]
		ranges[k] = range(range_start,range_start+ratios[k])
		range_start += ratios[k]
		
	var rand = randi_range(0,sum-1)
	for r in ranges.keys():
		if rand in ranges[r]:
			return r

# Music

const tracks = {
	"lobby":"res://music/The Lobby_Loopable.mp3",	
	"combat":"res://music/College Quarrel_Loopable.mp3",
	"printerboss":"res://music/Printing Issue_Loopable.mp3",
}

var current_track : String

func music_play(track_name:String):
	var default_volume = -15.0
	var tween := create_tween()
	tween.tween_property(Music,"volume_db",-80.0,1.0).from(default_volume)
	await tween.finished
	Music.stream = load(tracks[track_name])
	Music.stream.set("loop",true)
	Music.playing = true
	current_track = track_name
	tween = create_tween()
	tween.tween_property(Music,"volume_db",default_volume,1.0).from(-80.0)
	return Music.stream

func screen_shake(amplitude=16):
	var ShakeTween = create_tween().set_trans(Tween.TRANS_CUBIC)
	for i in 10:
		var rand = Vector2()
		rand.x = randf_range(-amplitude, amplitude)
		rand.y = randf_range(-amplitude, amplitude)

		ShakeTween.tween_property(Cam, "offset", rand, 0.1)
	ShakeTween.tween_property(Cam, "offset", Vector2.ZERO, 0.1)

# Abilities

func use_ability(character:String,by:Node):
	var ability_price = {
		"darwin":2,
		"gun":2,
	}
	if by.brainpower <= 0 or by.brainpower < ability_price.get(character):
		return
	by.brainpower -= ability_price.get(character)
	match character:
		"darwin":
			var minion = spawn_from_ability(Global.pick_by_percentage({"dood":3,"super_dood":6,"wizard_dood":1}),by.position,by)
			by.emit_signal("spawns_minion",minion)
		"gun":
			var aim_vec = by.position.direction_to(Main.get_global_mouse_position()+Vector2(0,by.mouse_aim_offset))
			for i in 30:
				var proj = Global.spawn_projectile(self,"gun_proj_1",by.position+Vector2(0,-by.mouse_aim_offset),aim_vec.normalized(),true)
				await get_tree().create_timer(0.02).timeout
				proj.t = create_tween().set_loops()
				var deg = deg_to_rad(35*[-1,1].pick_random())
				proj.t.tween_property(proj,"direction",aim_vec.rotated(deg),0.5)
				proj.t.chain().tween_property(proj,"direction",aim_vec.rotated(deg_to_rad(randf_range(0,-10))),0.5)
				proj.t.chain().tween_property(proj,"direction",aim_vec.rotated(deg*-1),0.5)
				by.emit_signal("spawns_bullet",proj)
