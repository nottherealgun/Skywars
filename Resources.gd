extends Node
# Resources

@onready var Main = get_node("/root/Main")
@onready var Map = get_node("/root/Main/Map")
@onready var GUI = get_node("/root/Main/GUI")
@onready var Dev = get_node("/root/Main/GUI/Dev")

@onready var MAP_RECT : Vector2 = Map.get_used_rect().size*128

# Entities

var active_entities = []

func spawn_projectile(proj_name:String,pos:Vector2,dir:Vector2,dmg:=1):
	var new_proj = load("res://"+proj_name+".tscn").instantiate()
	new_proj.position = pos
	new_proj.direction = dir
	new_proj.damage = dmg
	active_entities.append(new_proj)
	Main.add_child(new_proj)
	return new_proj

func spawn_enemy(enemy_name:String,pos:Vector2):
	var new_enemy = load("res://"+enemy_name+".tscn").instantiate()
	new_enemy.position = pos
	new_enemy.target = Main.get_node("Player")
	active_entities.append(new_enemy)
	Main.add_child(new_enemy)
	return new_enemy
	
func kill(entity:Node):
	active_entities.erase(entity)
	entity.queue_free()

func kill_all():
	for e in active_entities:
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
	var new_door = load("res://door.tscn").instantiate()
	var new = get_door_pos(room_size)
	new_door.position = new[0]
	new_door.horizontal = new[1]
	new_door.side = new[2]
	return new_door

func install_door(node:Node):
	active_doors.append(node)
	Main.add_child(node)

# Levels
@onready var testmap = load("res://adit_building_1.tscn").instantiate()

func sync_map():
	var target_map = testmap
	LevelManager.clear_level()
	
	for tile in target_map.get_node("Map").get_used_cells(0):
		Map.set_cell(0,Vector2i(tile.x,tile.y),0,Vector2i(34,1))
	MAP_RECT = Map.get_used_rect().size*128
	
	for entity in target_map.get_children():
		if entity is TileMap or entity is Marker2D:
			continue
		target_map.remove_child(entity)
		Main.add_child(entity)
		
		if entity.is_in_group("enemy"):
			entity.target = Main.get_node("Player")
