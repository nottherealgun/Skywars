extends Interactable

func _ready():
	randomize()
	$Sprite.texture = load("res://interactables/book"+str((randi()%2)+1)+".png")
