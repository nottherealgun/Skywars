@icon("res://projectiles/paperProjectile1.png")
class_name Projectile extends Area2D

var shooter
var health = 1
var direction := Vector2.RIGHT
var current_speed = 1
var knockback = 0

#@onready var tween = self.create_tween()
@export var damage = 1
var player_bullet = false 

func _enter_tree():
	if player_bullet:
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		$Sprite.modulate = Color.WHITE.blend(Color(1.0,0,0,0.2))

func _ready():
	pass

func _process(delta):
	# Movement
	position += direction * delta * current_speed * 250
	$Dev.text = str(player_bullet)
	
func affect(victim:Node):
	victim.health -= damage
	if player_bullet:
		victim.latest_shooter = shooter
#		victim.get_knockback(direction,knockback)
	Global.emit_indicator(damage,victim.position,player_bullet)

func _on_visible_on_screen_notifier_2d_screen_exited():
	Global.kill(self)

func _on_area_entered(area):
	if area.is_in_group("projectile"):
		if area.player_bullet != player_bullet:
			Global.kill(area)
			Global.kill(self)

func _on_body_entered(_body):
	Global.kill(self)
