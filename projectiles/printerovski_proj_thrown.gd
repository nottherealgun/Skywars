extends Node2D

signal thrown

var start_pos : Vector2

func _ready():
	var tween := create_tween()
	randomize()
	var new_pos = start_pos.x+randf_range(-300,300)
	tween.tween_property(self,"position",Vector2(new_pos,-1000+(randf_range(0,10)*-20)),1.0+randf_range(0,3.0))
	await tween.finished
	emit_signal("thrown")
	Global.kill(self)
