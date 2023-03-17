extends Node2D

@export var front_facing := true
@export_file("*.tscn") var room
@export_placeholder("Room Name") var devtext = ""

var players_in_vicinity = []

func _ready():
	$Dev.text = devtext
	match front_facing:
		false:
			$Sprite.animation = "side"
		true:
			$Sprite.animation = "forward"

func enter_room(player):
	var room_scene : PackedScene
	if room == null:
		room_scene = load("res://rooms/"+Global.rooms[randi()%Global.rooms.size()]["file"])
	else:
		room_scene = load(room)
	$Sprite.play()
	await $Sprite.animation_finished
	Global.sync_map(room_scene)

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
