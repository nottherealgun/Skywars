extends Node2D

func start():
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color.TRANSPARENT,5)
	await tween.finished
	queue_free()
