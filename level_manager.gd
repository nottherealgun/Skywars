extends Node
# Level Manager

@onready var map = Global.Map
var rooms = []
var current_room
	
func clear_level():
	Global.kill_all(["minion"])
	for d in Global.active_doors:
		Global.kill(d)
	
	for e in Global.active_entities:
		if (is_instance_valid(e) and e.is_in_group("minion")) or !is_instance_valid(e):
			continue
		Global.kill(e)
	
	Global.active_entities.clear()
	Global.active_doors.clear()
