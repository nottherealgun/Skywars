class_name Enemy extends CharacterBody2D

@export_placeholder("enemy_name") var display_name = ""
@export var max_health = 5
@onready var health = max_health
@export var speed = 1
@export var damage = 1

@export var level = 1
@export var points = 1
var latest_shooter : Node

var move_vec := Vector2.ZERO

var targets_in_range = []
var target : Node

func _ready():
#	$NameTag.text = display_name
#	$NameTag/LevelTag.text = "Lvl "+str(level)
#	$NameTag.modulate = Color8(255,255-(level*5),255-(level*5))
	max_health += level*2
	health = max_health
	points += level*2

func _physics_process(delta):
	if health <= 0:
		Global.kill(self)
	if !Global.is_out_of_map(position):
		Global.kill(self)
		
	if is_instance_valid(target):
		if target.fainted:
			target = null
			
	if !targets_in_range.is_empty():
#			target = targets_in_range[0]
		var dist = INF
		var closest
		for t in targets_in_range:
			if targets_in_range.is_empty() or t.fainted:
				break
			if t.position.distance_to(position) < dist:
				dist = t.position.distance_to(position)
				closest = t
		target = closest

func _move_update(delta):
	pass

var allies = []

func get_hurt(by:Node):
	by.affect(self)
	if by.is_in_group("projectile"):
		Global.kill(by)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("injured")
#	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
#	tween.tween_property($Healthbar,"value",(health*100)/max_health,0.5).from_current()
#	tween.parallel().tween_property($Healthbar,"scale:y",1.0,0.5).from(2.0)
#	$Healthbar.value = (health*100)/max_health

#func get_knockback(direction:Vector2,strength:=1):
#	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
##	tween.tween_property(self,"position",position+(direction*10*strength),0.2)
#	tween.tween_method(move_and_collide,Vector2.ZERO,(direction*strength*5),0.1)

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		get_hurt(area)
		
func _on_player_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		target = entity
		targets_in_range.append(entity)

func _on_player_detect_area_exited(area):
	var entity = area.get_parent()
	if entity == target:
		targets_in_range.erase(entity)

func _on_ally_detect_area_entered(area):
	var ally = area.get_parent()
	if not ally in allies:
		if ally.is_in_group("enemy") or ally.is_in_group("interactable"):
			allies.append(ally)

func _on_ally_detect_area_exited(area):
	var ally = area.get_parent()
	if ally in allies:
		allies.erase(ally)
