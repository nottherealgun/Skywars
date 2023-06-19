class_name Enemy extends CharacterBody2D

@export_placeholder("enemy_name") var display_name = ""
@export var max_health = 50
@onready var health = max_health : set = _set_health
@export var speed := 1
@export var damage := 10

@export var level := 0
@export var points := 1
var latest_shooter : Object

var move_vec := Vector2.ZERO

var targets_in_range = []
var target : Object

var DEFAULT = {}

var physics_vector : Vector2
var physics_tween : Tween

func _ready():
#	$NameTag.text = display_name
#	$NameTag/LevelTag.text = "Lvl "+str(level)
#	$NameTag.modulate = Color8(255,255-(level*5),255-(level*5))
	max_health += level*2
	health = max_health
	points += level*2
	
	DEFAULT["max_health"] = max_health
	DEFAULT["damage"] = damage
	DEFAULT["speed"] = speed

func _physics_process(delta):
	if health <= 0:
		Global.kill(self)
#	if !Global.is_out_of_map(position):
#		Global.kill(self)
	
	while null in targets_in_range:
		targets_in_range.erase(null)
		
	for t in targets_in_range:
		if !is_instance_valid(t):
			targets_in_range.erase(t)
			
	if !target:
		if !targets_in_range.is_empty():
			target = targets_in_range.pick_random()
			if !is_instance_valid(target):
				target = null
	
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
		if is_instance_of(closest, Object):
			target = closest

	if physics_tween and physics_tween.is_running():
		assert(physics_vector != null)
		if move_and_collide(physics_vector.normalized(),true):
			physics_tween.stop()

func physics_influence(tween:Tween,force_vec:Vector2):
	physics_tween = tween
	physics_vector = force_vec

func _move_update(delta):
	pass

## Privates

func _set_health(new_val):
	Global.emit_indicator((health-new_val),position,true)
	health = new_val

var allies = []

var og_scale = scale

func get_hurt(by:Object):
	by.affect(self)
	if by.is_in_group("projectile"):
		Global.kill(by)
#	$AnimationPlayer.stop()
#	$AnimationPlayer.play("injured")
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self,"scale",og_scale,0.5).from(og_scale*4/5)
	t.parallel().tween_property(get_node("Sprite"),"modulate",Color.WHITE,0.2).from(Color.RED)

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
