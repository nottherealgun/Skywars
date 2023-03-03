class_name Enemy extends Node2D

@export var max_health = 2
var health = max_health
@export var speed = 1
@export var damage = 1
var move_vec := Vector2.ZERO

var target : Node

func _ready():
	health = max_health

func _process(delta):
	$Sprite.flip_h = (move_vec.x > 0)
	$Healthbar.value = (health*100)/max_health
	if health <= 0:
		Global.kill(self)

func _move_update(delta):
#	if is_instance_valid(target):
#		move_vec = position.direction_to(target.position)
#		var allies_vec := Vector2.ZERO
#		for ally in allies:
#			if ally.position.distance_to(position) <= 50:
#				allies_vec += position.direction_to(ally.position)/5
#		position += (move_vec-allies_vec) * speed * delta * 50
	pass

var allies = []

func get_hurt(by:Node):
	by.affect(self)
	Global.kill(by)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("injured")

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		get_hurt(area)

func _on_ally_detect_area_entered(area):
	var ally = area.get_parent()
	if not ally in allies and ally.is_in_group("enemy"):
		allies.append(ally)

func _on_ally_detect_area_exited(area):
	var ally = area.get_parent()
	if ally in allies:
		allies.erase(ally)
