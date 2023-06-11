extends CharacterBody2D

@export var max_health = 100
@onready var health = max_health
@export var speed := 1
@export var damage = 50

var DEFAULT = {
	"max_health" = 100,
	"speed" = 1,
	"damage" = 50
}

var move_vec := Vector2.ZERO
var master : Object
var min_master_dist = 100
var shot = false

enum STATES {IDLE,FOLLOWING,CHASING,ATTACKING,DEATH}
var state = STATES.IDLE
var targets_in_range = [] as Array
var target : Object

var allies = []

func _process(delta):
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
	if !target and state != STATES.FOLLOWING:
		change_state(STATES.FOLLOWING)
		
	match state:
		STATES.IDLE:
			if position.distance_to(master.position) > min_master_dist:
				change_state(STATES.FOLLOWING)
				
			if is_instance_valid(target):
				change_state(STATES.CHASING)
				
		STATES.FOLLOWING:
			move_vec = position.direction_to(master.position)
			$AnimatedSprite2D.flip_h = (move_vec.x < 0)
			if $AnimatedSprite2D.frame >= 3:
				move((move_vec).normalized()*delta*speed*200)
				
			if position.distance_to(master.position) <= min_master_dist:
				change_state(STATES.IDLE)
				
			elif position.distance_to(master.position) > 500:
				position = master.position
				
			if is_instance_valid(target):
				change_state(STATES.CHASING)
		
		STATES.CHASING:
			move_vec = position.direction_to(target.position)
			if $AnimatedSprite2D.frame >= 3:
				move((move_vec).normalized()*delta*speed*200)
			if position.distance_to(target.position) < 25:
				change_state(STATES.ATTACKING)
		
		STATES.ATTACKING:
			if is_instance_valid(target):
				$AnimatedSprite2D.play("attack")
				$AnimatedSprite2D.flip_h = (target.position.x < position.x)
				if target.position.x < position.x:
					$PunchParticle.position.x = 35
				else:
					$PunchParticle.position.x = -35
					
				if $AnimatedSprite2D.frame == 4:
					$PunchParticle.emitting = true
				elif $AnimatedSprite2D.frame == 12:
					$PunchParticle.emitting = false
				
				if $AnimatedSprite2D.frame == 15 and $BetweenShots.is_stopped():
					target.get_hurt(self)
					$BetweenShots.start()
				await $AnimatedSprite2D.animation_finished
				$AnimatedSprite2D.play("idle")
	
			else:
				change_state(STATES.IDLE)
		
		STATES.DEATH:
			await $AnimatedSprite2D.animation_finished
			Global.kill(self)

func move(main_vec:Vector2):
	var checked_vec = main_vec*1.5
	var c = move_and_collide(checked_vec,true)
	var new_vec := Vector2.ZERO
	var a := Vector2.ZERO
	
	for i in 10:
		a = checked_vec.normalized().rotated(deg_to_rad(i*36))*200
		c = move_and_collide(a,true)
		if c and !is_instance_of(c.get_collider(),TileMap) and !c.get_collider().is_in_group("door"):
			var dist = position.distance_to(c.get_collider().position)-100
			var direc = position.direction_to(c.get_collider().position)
			var vec = direc*dist
			new_vec = vec
#			checked_vec -= direc/dist*5
	
	checked_vec += detect_allies()
	move_and_collide(checked_vec)
	
	$test.set_point_position(1,checked_vec*100)
	$test2.set_point_position(1,new_vec)
#	$test3.set_point_position(1,checked_vec.normalized().rotated(deg_to_rad(-50))*200)
#	$test3.set_point_position(2,checked_vec.normalized().rotated(deg_to_rad(50))*200)
	$test3.set_point_position(1,a)
		
		
func detect_allies():
	var allies_vec := Vector2.ZERO
	var range := 50
	for ally in allies:
		if ally.position.distance_to(position) <= range:
			var rot : float
			var a = position.direction_to(ally.position).rotated(PI*2/3)*100
			var b = position.direction_to(ally.position).rotated(-PI*2/3)*100
			var c = move_vec.angle_to(position+a)
			var d = move_vec.angle_to(position+b)
			if c < d:
				rot = PI*2/3
			else:
				rot = -PI*2/3
			allies_vec += ally.position.direction_to(position).rotated(deg_to_rad(rot))
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
			
		STATES.CHASING:
			$AnimatedSprite2D.play("move")
			
		STATES.DEATH:
			$AnimatedSprite2D.play("death")

func affect(victim:Object):
	victim.health -= damage

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
