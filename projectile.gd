@icon("res://paperProjectile1.png")
class_name Projectile extends Area2D

var shooter : Node
var health = 1
var direction := Vector2.RIGHT
var current_speed = 1

@onready var tween = self.create_tween()
@export var damage = 1
var player_bullet = false 

func _enter_tree():
	if !player_bullet:
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)

func _ready():
	var original_speed = current_speed
	current_speed *= 4
	tween.call_deferred("tween_property",self,"current_speed",original_speed,0.25)

func _process(delta):
	# Movement
	position += direction * delta * current_speed * 150

func affect(victim:Node):
	victim.health -= damage
	if player_bullet:
		victim.latest_shooter = shooter

func _on_visible_on_screen_notifier_2d_screen_exited():
	Global.kill(self)

func _on_area_entered(area):
	if area.is_in_group("projectile"):
		if area.player_bullet != player_bullet:
			Global.kill(area)
			Global.kill(self)
