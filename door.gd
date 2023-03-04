@tool
extends Node2D

@export var horizontal := true
@export var room : PackedScene

var players_in_vicinity = []

func _ready():
#	PlayerManager.connect("interact",enter_room)
	if !horizontal:
		$Sprite.rotation_degrees = 90

func enter_room(player):
	if player in players_in_vicinity:
		pass

func _on_area_2d_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player") and not entity in players_in_vicinity:
		players_in_vicinity.append(entity)

func _on_area_2d_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player") and entity in players_in_vicinity:
		players_in_vicinity.erase(entity)
