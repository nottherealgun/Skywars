extends Projectile

func _ready():
	super()
	$Sprite.look_at(position-direction*100)
	if direction.x > 0:
		$Sprite.flip_v = true
