@tool
extends Interactable

@export_enum("front","side") var facing = 0

func _process(delta):
	$Sprite.texture = load("res://assets/interactables/adithWoodLongChair"+["","Side"][facing]+".png")
