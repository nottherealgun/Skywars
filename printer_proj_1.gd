extends Projectile

func _ready():
	$Sprite.look_at(position-direction*2)
