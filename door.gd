@tool
extends Node2D

@export var horizontal := true

var players_in_vicinity = []
var room : Dictionary
var return_door = false
var side

func _ready():
	PlayerManager.connect("interact",enter_room)
	if !horizontal:
		$Sprite.rotation_degrees = 90

func enter_room(player):
	if player in players_in_vicinity:
		if room == {}:
			if return_door:
				room = LevelManager.make_room()
			else:
				room = LevelManager.make_room(self)
			$Dev.text = str(room)
		else:
			LevelManager.clear_level()
			LevelManager.install_room(room)

func _on_area_2d_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player") and not entity in players_in_vicinity:
		players_in_vicinity.append(entity)

func _on_area_2d_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player") and entity in players_in_vicinity:
		players_in_vicinity.erase(entity)
