class_name Enemy extends Node2D

@export var max_health = 2
var health = max_health
@export var speed = 1
@export var damage = 1
var move_vec := Vector2.ZERO

var target : Node

func _process(delta):
	_move_update(delta)
	if health <= 0:
		Global.destroy(self)

func _move_update(delta):
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= 200:
				allies_vec -= position.direction_to(ally.position)
		position += move_vec * speed * delta * 100 + allies_vec

var allies = []

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		area.affect(self)
		Global.destroy(area)

func _on_ally_detect_area_entered(area):
	var ally = area.get_parent()
	if not ally in allies and ally.is_in_group("enemy"):
		allies.append(ally)

func _on_ally_detect_area_exited(area):
	var ally = area.get_parent()
	if ally in allies:
		allies.erase(ally)
