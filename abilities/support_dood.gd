extends CharacterBody2D

@export var max_health = 10
@onready var health = max_health
@export var speed := 1

var move_vec := Vector2.ZERO
var master : Node
var min_master_dist = 100
var shot = false

enum STATES {IDLE,FOLLOWING,ATTACKING,DEATH}
var state = STATES.IDLE
var targets_in_range = [] as Array
var target : Node

var allies = []

func _process(delta):
#	$Label.text = str(is_instance_valid(target))
	if !is_instance_valid(target):
		for t in targets_in_range:
			if !is_instance_valid(t):
				targets_in_range.erase(t)
		if !targets_in_range.is_empty():
			target = targets_in_range.pick_random()
		
	match state:
		STATES.IDLE:
			if position.distance_to(master.position) > min_master_dist:
				change_state(STATES.FOLLOWING)
				
			if is_instance_valid(target):
				change_state(STATES.ATTACKING)
				
		STATES.FOLLOWING:
			move_vec = position.direction_to(master.position)
			$AnimatedSprite2D.flip_h = (move_vec.x < 0)
			if $AnimatedSprite2D.frame >= 3:
				move_and_collide((move_vec+detect_allies()).normalized()*delta*speed*200)
				
			if position.distance_to(master.position) <= min_master_dist:
				change_state(STATES.IDLE)
				
			elif position.distance_to(master.position) > 500:
				position = master.position
				
			if is_instance_valid(target):
				change_state(STATES.ATTACKING)
			
		STATES.ATTACKING:
			if is_instance_valid(target) and $BetweenShots.is_stopped():
				$AnimatedSprite2D.play("attack")
				$AnimatedSprite2D.flip_h = (target.position.x < position.x)
				if $AnimatedSprite2D.frame == 6 and !shot:
					var vine = Global.spawn_projectile(master,"dood_vines",position,position.direction_to(target.position),true)
					shot = true
				await $AnimatedSprite2D.animation_finished
				$AnimatedSprite2D.play("idle")
				$BetweenShots.start()
				
			else:
				change_state(STATES.IDLE)
				
func detect_allies():
	var allies_vec := Vector2.ZERO
	var range := 50
	for ally in allies:
		if ally.position.distance_to(position) <= range:
#				allies_vec += ((position.direction_to(ally.position))/ally.position.distance_to(position))*10
			var rot : float
			var a = position.direction_to(ally.position).rotated(PI*2/3)*100
			var b = position.direction_to(ally.position).rotated(-PI*2/3)*100
			var c = move_vec.angle_to(position+a)
			var d = move_vec.angle_to(position+b)
#				$a.set_point_position(1,a)
#				$b.set_point_position(1,b)
			if c < d:
				rot = PI*2/3
			else:
				rot = -PI*2/3
			allies_vec = ally.position.direction_to(position).rotated(deg_to_rad(rot))
	return allies_vec
	
func change_state(new_state):
	# Before
	match state:
		_:
			pass
	
	state = new_state
	
	# After
	match state:
		STATES.IDLE:
			$AnimatedSprite2D.play("idle")
			
		STATES.FOLLOWING:
			$AnimatedSprite2D.play("move")
			
		STATES.ATTACKING:
			pass
			
		STATES.DEATH:
			$AnimatedSprite2D.play("death")
			
func _on_enemy_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("enemy"):
		target = entity
		targets_in_range.append(entity)

func _on_enemy_detect_area_exited(area):
	var entity = area.get_parent()
	if entity == target:
		targets_in_range.erase(entity)
		change_state(STATES.IDLE)

func _on_ally_detect_area_entered(area):
	var ally = area.get_parent()
	if not ally in allies:
		if ally.is_in_group("minion") or ally.is_in_group("interactable"):
			allies.append(ally)

func _on_ally_detect_area_exited(area):
	var ally = area.get_parent()
	if ally in allies:
		allies.erase(ally)

func _on_timer_timeout():
	change_state(STATES.DEATH)
	await $AnimatedSprite2D.animation_finished
	Global.kill(self)

func _on_between_shots_timeout():
	shot = false
