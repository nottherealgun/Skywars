extends CharacterBody2D

@export var max_health = 10
@onready var health = max_health
@export var speed := 1
@export var damage = 5

var move_vec := Vector2.ZERO
var master : Node
var min_master_dist = 100
var shot = false

enum STATES {IDLE,FOLLOWING,BUFFING,DEATH}
var state = STATES.IDLE
var targets_in_range = [] as Array
var target : Node

var allies = []

func _process(delta):
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
			else:
				if master.health < master.max_health:
					change_state(STATES.BUFFING)
				
#			if is_instance_valid(target):
#				change_state(STATES.CHASING)
				
		STATES.FOLLOWING:
			move_vec = position.direction_to(master.position)
			$AnimatedSprite2D.flip_h = (move_vec.x < 0)
			if $AnimatedSprite2D.frame >= 3:
				move_and_collide((move_vec+detect_allies()).normalized()*delta*speed*200)
				
			if position.distance_to(master.position) <= min_master_dist:
				change_state(STATES.IDLE)
				
			elif position.distance_to(master.position) > 500:
				position = master.position
		
		STATES.BUFFING:
			if is_instance_valid(master) and $BetweenShots.is_stopped():
				$AnimatedSprite2D.play("buff")
				$AnimatedSprite2D.flip_h = (master.position.x < position.x)
				
				if $AnimatedSprite2D.frame == 10 and !shot:
					master.health += 1
					Global.emit_indicator(1,master.position,false,true)
					spawn_circle()
					shot = true
					
				await $AnimatedSprite2D.animation_finished
				$AnimatedSprite2D.play("idle")
				$BetweenShots.start()
			else:
				change_state(STATES.IDLE)
		
		STATES.DEATH:
			await $AnimatedSprite2D.animation_finished
			Global.kill(self)

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
			
		STATES.BUFFING:
			$AnimatedSprite2D.play("buff")
			
		STATES.DEATH:
			$AnimatedSprite2D.play("death")

func affect(victim:Node):
	victim.health -= damage
	Global.emit_indicator(damage,victim.position,false)

func spawn_circle():
	var new_circle = $HealCircle.duplicate()
	master.add_child(new_circle)
	new_circle.show()
	new_circle.start()
	return new_circle

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

func _on_between_shots_timeout():
	shot = false
