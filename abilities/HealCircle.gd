extends Node2D

func start():
	$Heal.play()
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color.TRANSPARENT,5)
	await tween.finished
	Global.kill(self)
