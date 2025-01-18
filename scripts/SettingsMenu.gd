extends Control

func _on_back_pressed():
	$AudioManager.play("click")
	$AnimationPlayer.play("exit")

func show():
	super()
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self,"position",Vector2.ZERO,1.0)
