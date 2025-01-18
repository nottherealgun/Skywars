@tool
extends Interactable

@export_enum("front","side","back") var facing = 0
@export var flip := false

func _process(delta):
	$Sprite.texture = load("res://interactables/adithChair"+["","Side","Back"][facing]+".png")
	$Sprite.flip_h = flip
