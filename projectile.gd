class_name Projectile extends Area2D

var direction := Vector2.RIGHT
var speed = 2
@export var damage = 1

func _process(delta):
	# Movement
	position += direction * delta * speed * 100

func affect(victim:Node):
	victim.health -= damage

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
