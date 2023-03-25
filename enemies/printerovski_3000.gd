extends CharacterBody2D

const display_name = "Printerovski 3000"
const display_desc = "MUIC Printer / Bane of Physical Copies"
@export var max_health = 400
@onready var health = max_health
@export var speed = 1
@export var damage = 3

@export var level = 1
@export var points = 1
var latest_shooter : Node

var move_vec := Vector2.ZERO

var targets_in_range = []
var target : Node

enum STATES {TRANSFORM,IDLE,MOVING,RELOADING,ATTACK1}
var state = STATES.TRANSFORM

func _ready():
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	$AnimatedSprite.position.y = -500
	tween.tween_property($AnimatedSprite,"position:y",128.0,1.0).from(-500.0).set_delay(4.0)
	tween.chain().tween_callback($AnimatedSprite.play.bind("transform"))
	await $AnimatedSprite.animation_finished
#	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
#	tween.tween_callback($AnimatedSprite.play.bind("idle"))
	$Hitbox.monitoring = true
#	$NameTag.text = display_name
#	$NameTag/LevelTag.text = "Lvl "+str(level)
#	$NameTag.modulate = Color8(255,255-(level*5),255-(level*5))
	max_health += level*2
	health = max_health
	points += level*2

func _physics_process(delta):
	
	if health <= 0:
		latest_shooter.money += points
		Global.kill(self)
		
	if is_instance_valid(target):
		var dis_to_target = (position+Vector2(0,46)).distance_to(target.position)
		$Pupil.position = Vector2(0,46)+((position+Vector2(0,46)).direction_to(target.position)*dis_to_target*20/500)
		$Pupil.scale = Vector2.ONE*(4-(dis_to_target*3.8/500))
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
	
	match state:
		STATES.TRANSFORM:
			await $AnimatedSprite.animation_finished
			change_state(STATES.IDLE)
		
		STATES.IDLE:
			if $Timer.is_stopped():
				$Timer.start(2.0)
				
		STATES.MOVING:
			if is_instance_valid(target):
				move_vec = position.direction_to(target.position)
				move_and_collide(move_vec*delta*speed*100)
				if $Timer.is_stopped():
					$Timer.start(2.0)
			else:
				change_state(STATES.IDLE)
				
		STATES.RELOADING:
			for i in 2:
				$AnimatedSprite.play("reload")
				await $AnimatedSprite.animation_finished
			change_state(STATES.IDLE)
			
		STATES.ATTACK1:
			await $AnimatedSprite.animation_finished
			change_state(STATES.RELOADING)

func change_state(new_state):
	match state:
		STATES.MOVING:
			$Pupil.hide()
	state = new_state
	match state:
		STATES.IDLE:
			$AnimatedSprite.play("idle")
		STATES.MOVING:
			$Pupil.show()
			$AnimatedSprite.play("move")
		STATES.ATTACK1:
			$AnimatedSprite.play("artillery")

var allies = []

func get_hurt(by:Node):
	by.affect(self)
	Global.kill(by)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("injured")
#	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
#	tween.tween_property($Healthbar,"value",(health*100)/max_health,0.5).from_current()
#	tween.parallel().tween_property($Healthbar,"scale:y",1.0,0.5).from(2.0)
#	$Healthbar.value = (health*100)/max_health

func get_knockback(direction:Vector2,strength:=1):
	pass # Bosses do not take knockback
#	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
##	tween.tween_property(self,"position",position+(direction*10*strength),0.2)
#	tween.tween_method(move_and_collide,Vector2.ZERO,(direction*strength*5),0.1)

func _on_hitbox_area_entered(area):
	var entity = area.get_parent()
	if area.is_in_group("projectile"):
		get_hurt(area)
	elif entity.is_in_group("player"):
		entity._injured_effect()
		entity.get_knockback(position.direction_to(entity.position),50)
		entity.health -= damage
		Global.emit_indicator(damage,entity.position,false)
	
func _on_player_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		target = entity
		targets_in_range.append(entity)

func _on_player_detect_area_exited(area):
	var entity = area.get_parent()
	if entity == target:
		targets_in_range.erase(entity)

#func _on_ally_detect_area_entered(area):
#	var ally = area.get_parent()
#	if not ally in allies:
#		if ally.is_in_group("enemy") or ally.is_in_group("interactable"):
#			allies.append(ally)
#
#func _on_ally_detect_area_exited(area):
#	var ally = area.get_parent()
#	if ally in allies:
#		allies.erase(ally)

func artillery_shot():
	var f_new_proj = load("res://projectiles/printerovski_proj_thrown.tscn").instantiate()
	f_new_proj.position = position+Vector2(136,-80)
	f_new_proj.start_pos = position+Vector2(136,-80)
	Global.Main.add_child(f_new_proj)
	Global.active_entities.append(f_new_proj)
	await f_new_proj.thrown
	
	var rand_land_pos
	while rand_land_pos == null or !Global.is_out_of_map(rand_land_pos):
		rand_land_pos = target.position+Vector2(randf_range(-300,300),randf_range(-300,300))
	
	randomize()
	var new_proj = load("res://projectiles/printerovski_proj.tscn").instantiate()
	new_proj.land_pos = rand_land_pos
	new_proj.printer_boss = self
	Global.active_entities.append(new_proj)
	Global.Main.add_child(new_proj)

func _on_animated_sprite_frame_changed():
	if state == STATES.ATTACK1:
		var a = $AnimatedSprite
		if a.frame in [19,22,25]:
			for i in 15:
				if is_instance_valid(target):
					artillery_shot()

func _on_timer_timeout():
	match state:
		STATES.IDLE:
			randomize()
			match randi_range(0,1):
				0:
					change_state(STATES.MOVING)
				1:
					change_state(STATES.ATTACK1)
					
		STATES.MOVING:
			change_state(STATES.IDLE)
