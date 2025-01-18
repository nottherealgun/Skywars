extends AnimatedSprite2D

var v = 500+randi_range(0,10)*20
var a = -10

var template = true

func _ready():
	if !template:
		var t = create_tween()
		randomize()
		t.tween_property(self,"position:x",randi_range(-100,100),1.0).as_relative()
		await get_tree().create_timer(5.0).timeout
		queue_free()

func _process(delta):
	if !template:
		position.y -= v * delta
		v += a
