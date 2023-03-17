extends Node
# Level Manager

@onready var map = Global.Map
var rooms = []
var current_room

@onready var testmap = load("res://rooms/"+Global.rooms[0].file)

func _ready():
	
	Global.sync_map(testmap)
	
func clear_level():
	Global.kill_all()
	for d in Global.active_doors:
		Global.Main.remove_child(d)
	
	Global.active_entities.clear()
	Global.active_doors.clear()

#func make_room(prev_door=null) -> Dictionary:
#	var new_room := {}
#	var placed_doors = []
#	new_room["size"] = Vector2i(15,15)
#	new_room["doors"] = []
#	new_room["entities"] = []
#	if current_room != null:
#		var door_to_prev = Global.new_door(current_room.size)
#		door_to_prev.return_door = true
#		door_to_prev.room = current_room
#		door_to_prev.position = prev_door.position
#		placed_doors.append(door_to_prev)
#		new_room["doors"].append(door_to_prev)
#
#	for i in 2:
#		var new_door = Global.new_door(new_room["size"])
#		while placed_doors.has(new_door.position):
#			new_door = Global.new_door(new_room["size"])
#		placed_doors.append(new_door.position)
#		new_room["doors"].append(new_door)
#	rooms.append(new_room)
#	return new_room

func install_room(room:Dictionary):
#	for x in room.size.x:
#		for y in room.size.y:
#			map.set_cell(0,Vector2i(x,y),0,Vector2i(33,1))
#	for d in room.doors:
#		Global.install_door(d)
#	current_room = room
	pass
