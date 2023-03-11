extends Node
# Resources

@onready var Main := get_node("/root/Main")
@onready var Map := get_node("/root/Main/Map")
@onready var GUI := get_node("/root/Main/GUI")
@onready var Dev := get_node("/root/Main/GUI/Dev")

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
		active_entities.erase(entity)
		entity.queue_free()

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
	
	# Prepare spawnpoints
	var target_map = map as Node2D
	var spawn_poses = []
	map_spawnpoint = target_map.find_child("SpawningPoint").position
	
	for p in active_players:
		var radius = 20
		spawn_poses.append(map_spawnpoint+Vector2(randi()%radius,randi()%radius))
		p.transporting = true
		p.y_sort_enabled = false

	# Transition
	var transition_screen = GUI.get_node("Transition")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	transition_screen.get_node("Tips").text = "Tip: "+str(tips[randi()%tips.size()])+"."
	tween.tween_property(transition_screen.material,"shader_parameter/progress",1.0,3).from(0.0)
	
	GUI.get_node("Title").text = target_map.name.capitalize()	
	
	tween.tween_property(transition_screen.material,"shader_parameter/progress",0.0,3).from(1.0)		
	tween.parallel().tween_property(GUI.get_node("Title"),"modulate",Color.WHITE,1.0).from(Color.TRANSPARENT)
	for p in active_players:
		tween.parallel().tween_property(p,"position",spawn_poses[active_players.find(p)],1)
	tween.tween_property(GUI.get_node("Title"),"modulate",Color.TRANSPARENT,1.0).from(Color.WHITE).set_delay(3.0)
	
	await tween.step_finished
	
	for p in active_players:
		p.transporting = false
		p.y_sort_enabled = true
	# Clear old map tiles
	Map.clear()
	LevelManager.clear_level()
	
	# Install map tiles
#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
#set_cells_terrain_connect(layer: int, cells: Array[Vector2i], terrain_set: int, terrain: int, ignore_empty_terrains: bool = true)

	for tile in target_map.get_node("Map").get_used_cells(0):
		var tile_type = target_map.get_node("Map").get_cell_atlas_coords(0,tile)
		Map.set_cell(0,tile,-1,tile_type)
	Map.set_cells_terrain_connect(0,target_map.get_node("Map").get_used_cells(0),0,0)
	
	for tile in target_map.get_node("Map").get_used_cells(1):
		var tile_type = target_map.get_node("Map").get_cell_atlas_coords(1,tile)
		# layer, coords, source_id, atlas_coords, alt_tile
		Map.set_cell(1,tile,-1,tile_type)
		# layer, cells, terrain_set,terrain
	Map.set_cells_terrain_connect(1,target_map.get_node("Map").get_used_cells(1),0,1)	
#	Map.set_cells_terrain_connect(1,target_map.get_node("Map").get_used_cells(1),0,1)
	
	MAP_RECT = Map.get_used_rect().size*128
	
	# Install map enemies
	for entity in target_map.get_children():
		if entity.get_class() in ["TileMap","Marker2D"]:
			continue
		target_map.remove_child(entity)
		active_entities.append(entity)
		Main.add_child(entity)

func emit_indicator(amnt:float,pos:Vector2,p_bullet=false):
	var new_indicator = load("res://utility/damage_indicator.tscn").instantiate()
	new_indicator.position = pos
	new_indicator.amount = roundi(amnt)
	new_indicator.player_bullet = p_bullet
	Main.add_child(new_indicator)
