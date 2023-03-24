extends Node2D

var land_pos : Vector2

var damage = 1
var landed = false

func _ready():
	var tween = create_tween() as Tween
	
	position = land_pos
	$Body.position = Vector2(0,-1000)
	tween.tween_property($Body,"position",Vector2(0,0),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Indicator,"modulate",Color.TRANSPARENT,3.0)
	await tween.finished
	$"Body/Sprite".stop()
	landed = true
	$Body.monitorable = false
	await get_tree().create_timer(2.0).timeout
	Global.kill(self)

func _process(delta):
#	$Dev.text = str($Body.position.y > -100.0 and landed == false)
	if $Body.position.y > -100.0 and landed == false:
		$Body.monitorable = true

func affect(victim:Node):
	victim.health -= damage
	Global.emit_indicator(damage,victim.position,false)
