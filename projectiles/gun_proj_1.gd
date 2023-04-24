extends Projectile

var t : Tween

func _ready():
	$Sprite.look_at(position+direction*100)

func queue_free():
	if t != null:
		t.kill()
	super()
