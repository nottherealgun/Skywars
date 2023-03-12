extends Node2D

func _ready():
	await $AnimatedSprite2D.animation_finished
	queue_free()
