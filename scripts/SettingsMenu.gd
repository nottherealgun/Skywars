extends Control

@export var audio_manager : Node

func _on_back_pressed():
	audio_manager.play("click")
	$AnimationPlayer.play("exit")

func show():
	super()
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self,"position",Vector2.ZERO,1.0)
