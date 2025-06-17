extends Interactable

func _ready():
	randomize()
	$Sprite.texture = load("res://assets/interactables/book"+str((randi()%2)+1)+".png")
