extends Node2D

var land_pos : Vector2

var printer_boss : CharacterBody2D
var damage = 5
var landed = false

func _ready():
	var tween = create_tween() as Tween
	var tween2 = create_tween() as Tween
	
	position = land_pos
	$Body.position = Vector2(0,-1000)
	tween.tween_property($Indicator,"scale",Vector2.ONE*5,1.0).from(Vector2.ZERO).set_trans(Tween.TRANS_ELASTIC)
	# Projectile Falling
	tween.chain().tween_property($Body,"position",Vector2(0,0),3.0/2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	# Red Indicator Fading
	tween2.tween_property($Indicator,"modulate",Color.TRANSPARENT,4.0/2)
	
	await tween.finished
	$Drop.stream = load("res://sfx/a4_drop/a4_drop"+str(randi_range(1,4))+".mp3")
	$Drop.play()
	
	$"Body/Sprite".stop()

	Global.emit_death_indicator(position)
	Global.kill(self)

func _process(_delta):
#	$Dev.text = str($Body.position.y > -110.0)
#	if $Body.position.y > -90.0:
#		$Body.monitorable = true
#	else:
#		$Body.monitorable = false
	$Body.monitorable = ($Body.position.y > -110.0)

func affect(victim:Node):
	victim.health -= damage
	Global.emit_indicator(damage,victim.position,false)
