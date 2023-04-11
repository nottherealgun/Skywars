extends Sprite2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta):
	position = get_global_mouse_position()
