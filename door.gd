@tool
extends Node2D

@export var horizontal := true
@export var room : PackedScene

var players_in_vicinity = []

func _ready():
	if !horizontal:
		$Sprite.rotation_degrees = 90

func enter_room(player):
	if not is_instance_valid(room):
		var random_room_path = DirAccess.get_files_at("res://rooms")[randi()%DirAccess.get_files_at("res://rooms").size()]
		room = load("res://rooms/"+random_room_path)
	var room_instance = room.instantiate()
	Global.sync_map(room_instance)

func _on_area_2d_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if !entity.is_connected("action",enter_room):
			entity.connect("action",enter_room)

func _on_area_2d_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if entity.is_connected("action",enter_room):
			entity.disconnect("action",enter_room)
