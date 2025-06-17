@tool
extends Interactable

@export_enum("front","side","back") var facing = 0

func _process(delta):
	$Sprite.texture = load("res://assets/interactables/adithWoodChair"+["","Side","Back"][facing]+".png")
