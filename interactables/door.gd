@tool
extends StaticBody2D

@export var front_facing := true
@export_file("*.tscn") var room
@export_placeholder("Room Name") var devtext = ""
var connected_room
@export var synced_with_new_map := false
const facing_pos = [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0)]
@export_enum("top","bottom","left","right") var facing_direction_idx = 0
var facing_vec = facing_pos[0]
var enterpoint := Vector2.ZERO
var connected_door : Node
var entrance = false

@export_category("Story Mode")
@export var synced_room : Node
@export var synced_room_door : Node
@export var oneshot := false

@export var boss := ""

var players_in_vicinity = []

func _get(property):
	match property:
		"facing_vec":
			return facing_pos[facing_direction_idx]

func _process(delta):
	if connected_door:
		$Dev.text = str(get_parent().name)
	else:
		$Dev.text = "Locked."
	match front_facing:
		false:
			$Sprite.animation = "side"
			
		true:
			$Sprite.animation = "forward"
			
	$Wide.disabled = !front_facing
	$Tall.disabled = front_facing

func enter_room(player):
	var room_scene : Node
	if room in [null,"","<null>"]:
		var rand_room_id : int
		while rand_room_id in [null,0,1]:
			rand_room_id = randi()%(Global.rooms.size()-1)
		room_scene = load("res://rooms/"+Global.rooms[rand_room_id]["file"]).instantiate()
	else:
		room_scene = load(room).instantiate()
	
	$Sprite.play()
	await $Sprite.animation_finished
	if synced_with_new_map:
		Global.sync_map(room_scene,boss)
	else:
		#Global.sync_room(room_scene)
		Global.exit_from_this_door(self,connected_door)
		
	$Sprite.frame = 0

func _on_area_2d_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if !entity.is_connected("does_action",enter_room):
			entity.connect("does_action",enter_room)

func _on_area_2d_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if entity.is_connected("does_action",enter_room):
			entity.disconnect("does_action",enter_room)
