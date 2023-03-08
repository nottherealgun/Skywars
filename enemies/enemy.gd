class_name Enemy extends Node2D

@export_placeholder("enemy_name") var display_name = ""
@export var max_health = 5
var health = max_health
@export var speed = 1
@export var damage = 1

@export var level = 1
@export var points = 1
var latest_shooter : Node

var move_vec := Vector2.ZERO

var target : Node

func _ready():
	$NameTag.text = display_name
	$NameTag/LevelTag.text = "Lvl "+str(level)
	$NameTag.modulate = Color8(255,255-(level*5),255-(level*5))
	max_health += level*2
	health = max_health
	points += level*2

func _process(delta):
	$Healthbar.value = (health*100)/max_health
	if health <= 0:
		latest_shooter.money += points
		Global.kill(self)
	if is_instance_valid(target):
		if target.fainted:
			target = null
	
	position.x = clampf(position.x, 0, Global.MAP_RECT.x)
	position.y = clampf(position.y, 0, Global.MAP_RECT.y)

func _move_update(delta):
#	if is_instance_valid(target):
#		move_vec = position.direction_to(target.position)
#		var allies_vec := Vector2.ZERO
#		for ally in allies:
#			if ally.position.distance_to(position) <= 50:
#				allies_vec += (position.direction_to(ally.position)*50)/ally.position.distance_to(position)
#		position += (move_vec-allies_vec) * speed * delta * 50
	pass

var allies = []

func get_hurt(by:Node):
	by.affect(self)
	Global.kill(by)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("injured")

func get_knockback(direction:Vector2,strength:=1):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"position",position+(direction*10*strength),0.2)

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		get_hurt(area)
		
func _on_player_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if target == null:
			target = entity

func _on_player_detect_area_exited(area):
	var entity = area.get_parent()
	if entity == target:
		target = null

func _on_ally_detect_area_entered(area):
	var ally = area.get_parent()
	if not ally in allies and ally.is_in_group("enemy"):
		allies.append(ally)

func _on_ally_detect_area_exited(area):
	var ally = area.get_parent()
	if ally in allies:
		allies.erase(ally)
