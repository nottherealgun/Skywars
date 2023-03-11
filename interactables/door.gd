extends Node2D

@export var horizontal := true
@export var room : Node2D

var players_in_vicinity = []

func _enter_tree():
	match horizontal:
		false:
			$Sprite.animation = "side"

func enter_room(player):
#	if room == null:
	room = Global.rooms[randi()%Global.rooms.size()]["file"].instantiate()
	$Sprite.play()
	await $Sprite.animation_finished
	Global.sync_map(room)

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
