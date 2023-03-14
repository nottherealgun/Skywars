extends Projectile

func _ready():
	$Sprite.look_at(get_global_mouse_position())
