@tool
extends StaticBody2D

@export var front_facing := true
@export_file("*.tscn") var room
@export_placeholder("Room Name") var devtext = ""

@export var synced_with_new_map := false
const facing_pos = [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0)]
@export_enum("top","bottom","left","right") var facing_direction_idx = 0

var facing_vec = facing_pos[0]
var enterpoint := Vector2.ZERO
var locked = false
var connected_door : Node
var entrance = false
var in_map : Array

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
#	if connected_door:
#		$Dev.text = str(get_parent().name)
#	else:
#		$Dev.text = "Locked."
	match front_facing:
		false:
			$Sprite.animation = "side"
			
		true:
			$Sprite.animation = "forward"
			
	$Wide.disabled = !front_facing
	$Tall.disabled = front_facing

func enter_room(player):
	
	locked = false
	if in_map[1].has_meta("entities"):
		for e in in_map[1].get_meta("entities"):
			if is_instance_valid(e) and e.is_in_group("enemy"):
				locked = true
				break

	if synced_with_new_map and !locked:
		$Sprite.play()
		await $Sprite.animation_finished
		Global.build_stage()
		GameManager.levels_cleared += 1
	else:
		if connected_door and !locked:
			$Sprite.play()
			await $Sprite.animation_finished
			Global.exit_from_this_door(self,connected_door)
		else:
			var t = create_tween().set_loops(3)
			t.tween_property($Sprite,"offset",Vector2(2,-32),0.1)
			t.chain().tween_property($Sprite,"offset",Vector2(0,-30),0.1)
		
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
