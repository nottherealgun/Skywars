@icon("res://projectiles/paperProjectile1.png")
class_name Projectile extends Area2D

var shooter : Object
var health = 1
var direction := Vector2.RIGHT
var current_speed = 1
var knockback = 0

#@onready var tween = self.create_tween()
@export var damage = 10
var damage_modifier = 1
var player_bullet = false 

func _enter_tree():
	if player_bullet:
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		$Sprite.modulate = Color.WHITE.blend(Color(1.0,0,0,0.2))
		set_collision_mask_value(5,false)

func _ready():
	pass

func _process(delta):
	# Movement
	position += direction * delta * current_speed * 350
	$Dev.text = str(player_bullet)
	
func affect(victim:Object):
	var calc_damage = damage
	if player_bullet:
		victim.latest_shooter = shooter
		var dist = victim.position.distance_to(shooter.position)
		calc_damage = (10-(snapped(dist,100)/200)) * damage_modifier
#		victim.get_knockback(direction,knockback)
	for b in get_children():
		if b.is_in_group("buff"):
			remove_child(b)
			victim.add_child(b)
			b.activate()
	victim.health -= calc_damage
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	Global.kill(self)

func _on_area_entered(area):
	if area.is_in_group("projectile"):
		if area.player_bullet != player_bullet:
			Global.kill(area)
			Global.kill(self)
#	elif area.is_in_group("interactable"):
#		Global.kill(self)

func _on_body_entered(_body):
	Global.kill(self)
