@tool
extends Interactable

@export_enum("front","side","back") var facing = 0

func _process(delta):
	if Engine.is_editor_hint():
		$Sprite.texture = load("res://interactables/adithPodium"+["Back","Side",""][facing]+".png")
		
