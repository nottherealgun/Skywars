extends Node
signal enemy_killed(enemy)

# Resources

@onready var Main := get_node("/root/Main") as Node2D
@onready var Map := get_node("/root/Main/Map") as TileMap
@onready var GUI := get_node("/root/Main/GUI") as CanvasLayer
@onready var Dev := get_node("/root/Main/GUI/Dev") as Label
@onready var Music := get_node("/root/Main/Music") as AudioStreamPlayer
@onready var Bossbar := get_node("/root/Main/GUI/BossBar") as Control
@onready var PauseMenu := get_node("/root/Main/GUI/PauseMenu")
@onready var Cam := get_node("/root/Main/MainCam") as Camera2D

@onready var MAP_RECT : Vector2 = Map.get_used_rect().size*128

var current_map_uninit
var current_map
var current_map_boss

var cached_rooms = []
var active_players = []

# Entities

var active_entities = []

func spawn_projectile(shooter:Node,proj_name:String,pos:Vector2,dir:Vector2,player_bullet=false,dmg:=1):
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
	
func kill(entity:Node,immediate=false):
	if is_instance_valid(entity) and entity in active_entities:
		active_entities.erase(entity)
		var tween = create_tween()
		if immediate == false:
			tween.tween_property(entity,"scale",Vector2.ZERO,0.2)
			tween.chain().tween_callback(entity.queue_free)
		if entity.is_in_group("enemy"):
			tween.parallel().tween_callback(emit_death_indicator.bind(entity.position))
		elif entity.is_in_group("projectile"):
			entity.current_speed = 0
#		entity.queue_free()
		emit_signal("enemy_killed",entity)

func kill_all():
	while not active_entities.is_empty():
		var e = active_entities.front()
		if is_instance_valid(e):
			kill(e)

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
	{"file":"adit_single.tscn","name":"Single Room"},
	{"file":"adit_double.tscn","name":"Double Room"},
	{"file":"adit_l_shape_bl.tscn","name":"LShaped-BL Room"},
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
		spawn_boss(boss,MAP_RECT/4)
	
		# Set new player positions
	for p in active_players:
		if p.fainted:
			p.revive()
		p.position = spawn_poses[active_players.find(p)]
		p.transporting = false
		p.y_sort_enabled = true
	
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
	
	# Set new player positions
	for p in active_players:
		p.position = spawn_poses[active_players.find(p)]
		p.transporting = false
		p.y_sort_enabled = true
		if p.fainted:
			p.revive()

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

func is_out_of_map(pos:Vector2) -> bool:
	var map_local_pos = Map.to_local(pos)
	var cell = Map.local_to_map(map_local_pos)
	var data = Map.get_cell_tile_data(0,cell)
	if data:
		return true
	else:
		return false

# Utility

func emit_indicator(amnt:float,pos:Vector2,p_bullet=false):
	var new_indicator = load("res://utility/damage_indicator.tscn").instantiate()
	new_indicator.position = pos
	new_indicator.amount = roundi(amnt)
	new_indicator.player_bullet = p_bullet
	Main.add_child(new_indicator)

func emit_death_indicator(pos:Vector2):
	var new_particle = load("res://utility/death_indicator.tscn").instantiate()
	new_particle.position = pos
	Main.add_child(new_particle)

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
