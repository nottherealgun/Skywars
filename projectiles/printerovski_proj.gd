extends Node2D

var land_pos : Vector2

var printer_boss : CharacterBody2D
var damage = 3
var landed = false

func _ready():
	var tween = create_tween() as Tween
	var tween2 = create_tween() as Tween
	
	position = land_pos
	$Body.position = Vector2(0,-1000)
	# Projectile Falling
	tween.tween_property($Body,"position",Vector2(0,0),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	# Red Indicator Fading
	tween2.tween_property($Indicator,"modulate",Color.TRANSPARENT,4.0)
	
	await tween.finished
	$"Body/Sprite".stop()
	
#	landed = true
#	$Body.monitorable = false
#	await get_tree().create_timer(0.3).timeout

	randomize()
	if randi_range(0,100) < 10:
		if is_instance_valid(printer_boss):
			if is_instance_valid(printer_boss.target):
				if position.distance_to(printer_boss.target.position) < 150:
					Global.spawn_enemy("printer",position)
	Global.emit_death_indicator(position)
	Global.kill(self)

func _process(_delta):
#	$Dev.text = str($Body.position.y > -90.0)
	if $Body.position.y > -90.0:
		$Body.monitorable = true
	else:
		$Body.monitorable = false
#	$Body.monitorable = ($Body.position.y > -150.0)

func affect(victim:Node):
	victim.health -= damage
	Global.emit_indicator(damage,victim.position,false)
