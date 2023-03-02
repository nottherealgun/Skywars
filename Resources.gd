extends Node
# Resources

@onready var Main = get_node("/root/Main")
@onready var Map = get_node("/root/Main/TileMap")
@onready var GUI = get_node("/root/Main/GUI")
@onready var Dev = get_node("/root/Main/GUI/Dev")

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
	
func destroy(entity:Node):
	active_entities.erase(entity)
	entity.queue_free()

func kill_all():
	for e in active_entities:
		destroy(e)
