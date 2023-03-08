extends Projectile

func _ready():
	super()
	$Sprite.look_at(position-direction*2)
