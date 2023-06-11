extends CharacterBody2D
signal started()
signal died()

const display_name = "Printerovski 3000"
const display_desc = "MUIC Printer / Bane of Physical Copies"
@export var max_health = 4000
@onready var health = max_health : set = _set_health
@export var speed = 2
var speed_modifier = 1
@export var damage = 30

var DEFAULT = {
	"max_health" : max_health,
	"speed" : speed,
	"damage" : damage,
}

@export var level = 1
@export var points = 100
var latest_shooter : Object

var move_vec := Vector2.ZERO

var targets_in_range = []
var target : Object

enum STATES {TRANSFORM,IDLE,MOVING,RELOADING,ATTACK1,ATTACK2,FLYING,FALLING,DEATH}
var state = STATES.TRANSFORM

func _ready():
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	$AnimatedSprite.position.y = -500
	tween.tween_property($AnimatedSprite,"position:y",128.0,1.0).from(-500.0).set_delay(4.0)
	tween.chain().tween_callback($Shockwave.play.bind("default"))
	tween.chain().tween_callback($AnimatedSprite.play.bind("transform"))
	tween.parallel().tween_callback($Transform.play)
	
	await $AnimatedSprite.animation_finished
#	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
#	tween.tween_callback($AnimatedSprite.play.bind("idle"))
	$Hitbox.monitoring = true
#	$NameTag.text = display_name
#	$NameTag/LevelTag.text = "Lvl "+str(level)
#	$NameTag.modulate = Color8(255,255-(level*5),255-(level*5))
#	max_health += level*2
	health = max_health
	points += level*2

func _physics_process(delta):
#	print(STATES.keys()[state])
	if health <= 0 and state != STATES.DEATH:
		GameManager.add_money(points)
		change_state(STATES.DEATH)
#		$Hitbox.monitoring = false
		
	if is_instance_valid(target):
		var dis_to_target = (position+Vector2(0,46)).distance_to(target.position)
		$Pupil.position = Vector2(0,46)+((position+Vector2(0,46)).direction_to(target.position)*dis_to_target*20/500)
		$Pupil.scale = Vector2.ONE*(4.5-(dis_to_target*3.8/500))
		if target.fainted:
			target = null
	else:
		for p in Global.active_players:
			if !p.fainted:
				target = p
				break
			
	if !targets_in_range.is_empty():
#			target = targets_in_range[0]
		var dist = INF
		var closest
		for t in targets_in_range:
			if targets_in_range.is_empty() or t.fainted:
				break
			if t.position.distance_to(position) < dist:
				dist = t.position.distance_to(position)
				if t is Object == false:
					continue
				closest = t
		if is_instance_of(closest, Object):
			target = closest
	
	match state:
		STATES.TRANSFORM:
			await $AnimatedSprite.animation_finished
			change_state(STATES.IDLE)
		
		STATES.IDLE:
			if $Timer.is_stopped():
				$Timer.start(5.0)
				
		STATES.MOVING:
			if is_instance_valid(target):
				move_vec = position.direction_to(target.position)
				move_and_collide(move_vec*delta*speed*150*speed_modifier)
				if $Timer.is_stopped():
					$Timer.start(2.0)
			else:
				change_state(STATES.IDLE)
				
		STATES.FLYING:
			$LandIndicator.modulate = Color.WHITE
			$LandIndicator.position = target.position-position
			
		
func change_state(new_state):
	if !target and state != STATES.IDLE:
		new_state = STATES.IDLE
		
	match state:
		STATES.TRANSFORM:
			emit_signal("started")
		STATES.MOVING:
			$Pupil.hide()
			$Walk.stop()

	state = new_state
	match state:
		STATES.IDLE:
			$AnimatedSprite.play("idle")
			
		STATES.MOVING:
			$Pupil.show()
			$AnimatedSprite.play("move")
			$Walk.play()
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self,"speed_modifier",2.0,2.0).from(0.1)
			
			for i in 3:
				if is_instance_valid(target):
					var vec = -position.direction_to(target.get_hitbox_anchor()).rotated(deg_to_rad(-60))
					for j in 5:
						Global.spawn_projectile(self,"printer_proj_1",position,vec)
						vec = vec.rotated(deg_to_rad(30))
					await get_tree().create_timer(0.3).timeout
		
		STATES.RELOADING:
			if randi()%100 < 30:
				summon_nests()
			for i in range(0,3):
				
				$AnimatedSprite.play("reload")
				$Reload.play()
				
				await $AnimatedSprite.animation_finished
			change_state(STATES.IDLE)
			
		STATES.ATTACK1:
			$AnimatedSprite.play("artillery")
			$Artillery.play()
			await $AnimatedSprite.animation_finished
			change_state(STATES.RELOADING)
			
		STATES.ATTACK2:
			$Fly.play()
			$AnimatedSprite.play("jump")
			$Hitbox.monitoring = false
			await $AnimatedSprite.animation_finished
			change_state(STATES.FLYING)
			
		STATES.FLYING:
			$AnimatedSprite.play("fly")
			var tween = create_tween()
			tween.tween_property($AnimatedSprite,"position:y",-5000,3).from_current()
			await tween.finished
			change_state(STATES.FALLING)
			
		STATES.FALLING:
			$LandIndicator.position = Vector2.ZERO
			position = target.position
			$AnimatedSprite.play("falling")
			
			var tween := create_tween()
			tween.tween_property($AnimatedSprite,"position:y",128,2).from_current()
			tween.parallel().tween_property($LandIndicator,"modulate",Color.TRANSPARENT,2).from(Color.WHITE)
			await tween.finished
			
			$AnimatedSprite.play("crash")
			$Shockwave.play("default")
			$Crash.play()
			Global.screen_shake(16)
			for i in 2:
				var minion = Global.spawn_enemy("printer",position)
				var min_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				min_tween.tween_property(minion,"position",position+position.direction_to(target.position).rotated(deg_to_rad(randf_range(-90.0,90.0)))*300,1.0)
				
			await $AnimatedSprite.animation_finished
				
			$Hitbox.monitoring = true
			change_state(STATES.IDLE)
			
			for i in 5:
				crash_burst(i*45)
				await get_tree().create_timer(0.3).timeout
		
		STATES.DEATH:
			$AnimatedSprite.play("death")
			$Death.play()
			emit_signal("died")
			await $AnimatedSprite.animation_finished
			Global.kill(self)

## Privates

func _set_health(new_val):
	Global.emit_indicator((health-new_val),position,true)
	health = new_val

var allies = []

func get_hurt(by:Object):
	by.affect(self)
	if by.is_in_group("projectile"):
		Global.kill(by)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("injured")
	
func get_knockback(direction:Vector2,strength:=1):
	pass # Bosses do not take knockback
#	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
##	tween.tween_property(self,"position",position+(direction*10*strength),0.2)
#	tween.tween_method(move_and_collide,Vector2.ZERO,(direction*strength*5),0.1)

func _on_hitbox_area_entered(area):
	var entity = area.get_parent()
	if area.is_in_group("projectile"):
		get_hurt(area)
		
	elif entity.is_in_group("player") and state != STATES.DEATH:
		entity._injured_effect()
#		entity.get_knockback(position.direction_to(entity.position),50)
		entity.health -= damage
	
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
	
	var rand_land_pos = null
	while (rand_land_pos == null or Global.is_out_of_map(rand_land_pos)) and is_instance_valid(target):
		rand_land_pos = target.position+Vector2(randf_range(-300,300),randf_range(-300,300))
	
	var new_proj = load("res://projectiles/printerovski_proj.tscn").instantiate()
	new_proj.land_pos = rand_land_pos
	new_proj.printer_boss = self
	Global.active_entities.append(new_proj)
	Global.Main.add_child(new_proj)

func crash_burst(angle_mod=0):
	var vec = Vector2(0,1).rotated(deg_to_rad(angle_mod))
	for i in 18:
		Global.spawn_projectile(self,"printer_proj_2",position,vec)
		vec = vec.rotated(deg_to_rad(20))

func summon_nests():
	var room_data = Global.current_room.get_meta("metadata")
	var map = room_data[1]
	for i in 3:
		var nest = Global.spawn_enemy("paper_nest",Global.get_rand_room_tile(map))

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
			var r = randi_range(1,100)
			if r in range(1,45):
				change_state(STATES.MOVING)
			elif r in range(45,90):
				change_state(STATES.ATTACK1)
			elif r in range(90,100):
				change_state(STATES.ATTACK2)
					
		STATES.MOVING:
			change_state(STATES.IDLE)
