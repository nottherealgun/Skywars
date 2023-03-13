extends Node
signal enemy_killed(enemy)

# Resources

@onready var Main := get_node("/root/Main")
@onready var Map := get_node("/root/Main/Map")
@onready var GUI := get_node("/root/Main/GUI")
@onready var Dev := get_node("/root/Main/GUI/Dev")
@onready var Music := get_node("/root/Main/Music") as AudioStreamPlayer

@onready var MAP_RECT : Vector2 = Map.get_used_rect().size*128

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
	
func kill(entity:Node):
	if is_instance_valid(entity):
		if !entity.is_in_group("projectile"):
			emit_death_indicator(entity.position)
		active_entities.erase(entity)
		entity.queue_free()
		emit_signal("enemy_killed",entity)

func kill_all():
	while not active_entities.is_empty():
		var e = active_entities.front()
		if is_instance_valid(e):
			kill(e)

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
	var new_door = load("res://objects/door.tscn").instantiate()
	var new = get_door_pos(room_size)
	new_door.position = new[0]
	new_door.horizontal = new[1]
	new_door.side = new[2]
	return new_door

func install_door(node:Node):
	active_doors.append(node)
	Main.add_child(node)

var map_spawnpoint : Vector2

const rooms = [
	{"file":preload("res://rooms/adit_building_1.tscn"),"name":"Aditayathorn Building 1"}
]

const tips = [
	"Be careful of the ICT",
	"If you try really hard, you might be able to get an A"
]

# Levels
func sync_map(map):
	music_play("combat")
	# Prepare spawnpoints
	var target_map = map.instantiate()
	var spawn_poses = []
	map_spawnpoint = target_map.find_child("SpawningPoint").position
	
	for p in active_players:
		var radius = 20
		spawn_poses.append(map_spawnpoint+Vector2(randi()%radius,randi()%radius))
		p.transporting = true
		p.y_sort_enabled = false

	# Entry Transition
	var transition_screen = GUI.get_node("Transition")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	transition_screen.get_node("Tips").text = "Tip: "+str(tips[randi()%tips.size()])+"."
	tween.tween_property(transition_screen.material,"shader_parameter/progress",1.0,2).from(0.0)

	await tween.step_finished
	
	# Set level title name
#	for r in rooms:
#		if map.name == r["file"].instantiate().name:
#			GUI.get_node("Title").text = r["name"]
#			break
	GUI.get_node("Title").text = target_map.name.capitalize()
	
	# Set new player positions
	for p in active_players:
		p.position = spawn_poses[active_players.find(p)]
		p.transporting = false
		p.y_sort_enabled = true
		if p.fainted:
			p.revive()
	# Clear old map tiles
	Map.clear()
	LevelManager.clear_level()
	
	# Install map tiles
	for tile in target_map.get_node("Map").get_used_cells(0):
		var tile_type = target_map.get_node("Map").get_cell_atlas_coords(0,tile)
		Map.set_cell(0,tile,-1,tile_type)
	Map.set_cells_terrain_connect(0,target_map.get_node("Map").get_used_cells(0),0,0)
	
#	for tile in target_map.get_node("Map").get_used_cells(1):
#		var tile_type = target_map.get_node("Map").get_cell_atlas_coords(1,tile)
#		print(tile_type)
#		# layer, coords, source_id, atlas_coords, alt_tile
#		Map.set_cell(1,tile,-1,Vector2i(1,0))
#		# layer, cells, terrain_set,terrain
#	Map.set_cells_terrain_connect(1,target_map.get_node("Map").get_used_cells(1),1,0)	
	
	var terrains = {}
	var terrain_sets = {}
	
	for tile in target_map.get_node("Map").get_used_cells(1): # Layer 1
		var tile_atlas = target_map.get_node("Map").get_cell_atlas_coords(1,tile)
		var tile_data = target_map.get_node("Map").get_cell_tile_data(1,tile)
		
		terrains[tile] = {"atlas":tile_atlas,"terrain_set":tile_data.terrain_set,"terrain":tile_data.terrain}
		
	for t in terrains.keys():
		Map.set_cell(1,t,-1,terrains[t].atlas)
		if !terrain_sets.has(terrains[t].terrain_set):
			terrain_sets[terrains[t].terrain_set] = {}
			
		if terrain_sets.has(terrains[t].terrain_set):
			if terrain_sets[terrains[t].terrain_set].get(terrains[t].terrain) == null:
#				print(terrains[t].terrain)
				terrain_sets[terrains[t].terrain_set][terrains[t].terrain] = []
			
			if terrain_sets[terrains[t].terrain_set].get(terrains[t].terrain) != null:
				terrain_sets[terrains[t].terrain_set].get(terrains[t].terrain).append(t)
				
#	print_rich(terrain_sets)
	for terrain_set_id in terrain_sets.keys(): # Terrain Set
		for terrain_id in terrain_sets.get(terrain_set_id).keys(): # Terrain
			var tile_arr = []
			for tile in terrain_sets.get(terrain_set_id).get(terrain_id): # Tile
				tile_arr.append(tile)
			
			print(tile_arr,"+",terrain_set_id,"-",terrain_set_id)
			print("\n")
			Map.set_cells_terrain_connect(1,tile_arr,terrain_set_id,terrain_id)
	
	# Install map enemies
	for entity in target_map.get_children():
		if entity.get_class() in ["TileMap","Marker2D"]:
			continue
		target_map.remove_child(entity)
		active_entities.append(entity)
		Main.add_child(entity)
		
	# Exit Transition
	tween = create_tween()
	tween.tween_property(transition_screen.material,"shader_parameter/progress",0.0,1.5).from(1.0)
	tween.chain().tween_property(GUI.get_node("Title"),"modulate",Color.WHITE,1.0).from(Color.TRANSPARENT)
	tween.chain().tween_property(GUI.get_node("Title"),"modulate",Color.TRANSPARENT,1.0).from(Color.WHITE).set_delay(3.0)
	
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
	"default":"res://music/The Lobby_Loopable.mp3",	
	"combat":"res://music/Combat_Music_Loopable.mp3",
}

func music_play(track_name:String):
	var default_volume = -5.0
	var tween := create_tween()
	tween.tween_property(Music,"volume_db",-80.0,1.0).from(default_volume)
	await tween.finished
	Music.stream = load(tracks[track_name])
	Music.playing = true
	tween = create_tween()
	tween.tween_property(Music,"volume_db",default_volume,1.0).from(-80.0)
	
