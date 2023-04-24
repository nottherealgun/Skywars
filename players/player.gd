class_name Player extends CharacterBody2D

signal action(by)
signal player_killed(player)

# Player device settings
@export var player_id = 1
@export_enum("darwin","gun") var character = "darwin"
@onready var player_color = [Color.DODGER_BLUE,Color.CORAL,Color.DARK_GREEN,Color.MEDIUM_PURPLE][player_id-1]
# Player stats
@export var max_health = 1
@onready var health = max_health
@export var brainpower = 6
@export var speed = 1
var equipped_item : Dictionary

var minions = []

# Internal stats
var move_vec := Vector2.ZERO
var aim_vec := Vector2.ZERO
var fainted = false
var transporting = false
var iframed = false

const hitbox_anchor = Vector2(0,44)

var latest_shooter
var revival_target : Player
# Player GUI setup
@onready var stat_gui = Global.GUI.get_node("PlayerStats/PlayerStats"+str(player_id))
@onready var healthbar = stat_gui.get_node("Healthbar")
@onready var brainbar = stat_gui.get_node("Brainbar")

# Tweens
@onready var injury_tween : Tween

var mouse_aim_offset = 0

func _ready():
	# Setup player appearance and GUI settings
	$Arrow.modulate = player_color
	$Sprite.sprite_frames = load("res://players/"+character+".tres")
	$Sprite.play("idle")
	stat_gui.show()
	stat_gui.get_node("Icon").texture = load("res://players/"+character+"_head.png")
	stat_gui.get_node("NameTag").set("theme_override_colors/font_color",player_color)
	stat_gui.get_node("NameTag").text = "Player "+str(player_id)
	
func _process(delta):
	$dev.text = str(iframed)
	_input_update() # Update device input
	_gui_update() # Update gui
	var sprite = get_node("Sprite")
	if health <= 0: # If player dies
		if !fainted:
			sprite.play("faint")
			fainted = true
			$Arrow.hide()
			$Revival.show()
			emit_signal("player_killed",self)
			
	if fainted:
		if $Revival.value == 100.0:
			revive()
				
	if !fainted and !transporting and !Global.PauseMenu.visible and !Global.Inventory.visible: # If player alive
		_move_update(delta) # Update movement
		# Sprite H flipping
		if move_vec != Vector2.ZERO:
			sprite.animation = "run"
			if move_vec.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
		else:
			sprite.animation = "idle"

func _input_update():
	# Get movement input strength
	aim_vec = Input.get_vector("p"+str(player_id)+"_left2","p"+str(player_id)+"_right2","p"+str(player_id)+"_up2","p"+str(player_id)+"_down2")
	
	if !fainted and !transporting and !Global.PauseMenu.visible: # If player alive
		if !Global.Inventory.visible:
			get_node("Arrow").rotation = get_node("Arrow").position.angle_to_point(aim_vec)
			get_node("Arrow").visible = (aim_vec != Vector2.ZERO)
			if Input.is_action_pressed("p"+str(player_id)+"_primary") and $RateOfFire.is_stopped():
				$RateOfFire.start()
				# Primary
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					aim_vec = position.direction_to(get_global_mouse_position()+Vector2(0,mouse_aim_offset))
				if aim_vec != Vector2.ZERO:
					shoot()
				
			if Input.is_action_just_pressed("p"+str(player_id)+"_action"):
				# Action1
				emit_signal("action",self)
			
			if Input.is_action_just_pressed("p"+str(player_id)+"_secondary"):
				# Ability
				Global.use_ability(character,self)
				
			if Input.is_action_just_pressed("p"+str(player_id)+"_dash"):
				# Dash
				if move_vec != Vector2.ZERO:
					if move_and_collide(move_vec*150,true) == null and $DashDelay.is_stopped():
						$DashDelay.start(0.5)
#						var temp = [$Sprite.offset,$Sprite.position]
#						$Sprite.offset = Vector2.ZERO
#						$Sprite.position = Vector2.ZERO
						var t = create_tween()
						t.tween_property(self,"position",move_vec*150,0.2).as_relative()
						if move_vec.normalized().x < 0:
							t.parallel().tween_property($Sprite,"rotation",0,0.25).from(PI*2)
						else:
							t.parallel().tween_property($Sprite,"rotation",0,0.25).from(-PI*2)

						await t.finished
#						$Sprite.offset = Vector2(0,-24)
#						$Sprite.position = Vector2(0,48)
					
			if Input.is_action_pressed("p"+str(player_id)+"_action"):
				if is_instance_valid(revival_target) and revival_target.fainted:
					if revival_target.get_node("ReviveTimer").is_stopped():
						revival_target.get_node("ReviveTimer").start()
					
					if !revival_target.fainted:
						revival_target = null
		
		if Input.is_action_just_pressed("inventory"):
			Global.Inventory.visible = !Global.Inventory.visible

func _gui_update():
	healthbar.value = (health*healthbar.max_value)/max_health
	brainbar.frame = brainpower

func _move_update(delta):
	move_vec = Input.get_vector("p"+str(player_id)+"_left","p"+str(player_id)+"_right","p"+str(player_id)+"_up","p"+str(player_id)+"_down")

#	position += move_vec.normalized()*delta*speed*200
#	position.x = clampf(position.x, 0+32, Global.MAP_RECT.x-32)
#	position.y = clampf(position.y, 0, Global.MAP_RECT.y)
	move_and_collide(move_vec.normalized()*delta*speed*200)

func shoot():
	match character:
		"darwin":
			var player_proj = Global.spawn_projectile(self,"darwin_proj_1",position+Vector2(0,-mouse_aim_offset),aim_vec.normalized(),true)
		"gun":
			var player_proj = Global.spawn_projectile(self,"gun_proj_1",position+Vector2(0,-mouse_aim_offset),aim_vec.normalized(),true)
		_:
			var player_proj = Global.spawn_projectile(self,"gun_proj_1",position+Vector2(0,-mouse_aim_offset),aim_vec.normalized(),true)

#	player_proj.set("knockback",1)
#func get_knockback(direction:Vector2,strength:=1):
#	var tween := create_tween()
#	tween.tween_property(self,"position",position+(direction*strength),0.2)

func _injured_effect():
	var sprite = $Sprite
	injury_tween = create_tween()
	injury_tween.tween_property(sprite,"modulate",Color.WHITE,0.5).from(Color.RED)
	injury_tween.parallel().tween_property(sprite,"scale",Vector2(2,2),0.5).from(Vector2(2,2)*0.8).set_trans(Tween.TRANS_CUBIC)
	Input.start_joy_vibration(player_id-1,1,0,0.2)
	
	injury_tween = create_tween().set_loops(2).bind_node(self)
	injury_tween.tween_property(sprite,"modulate",Color.WHITE,0.5).from(Color.TRANSPARENT)

func get_hurt(by:Node):
	if !iframed:
		iframed = true
		by.affect(self)
		_injured_effect()
		await injury_tween.finished
		iframed = false

func revive():
	$Guide.hide()
	health = max_health
	get_node("Sprite").play("idle")
	fainted = false
	get_node("Revival").hide()

func get_surround_pos() -> Vector2:
	var new_surr_pos := position+Vector2(0,1)
	new_surr_pos.rotated(deg_to_rad(randf()*360.0))
	return new_surr_pos

func get_hitbox_anchor():
	return position+hitbox_anchor

func _on_hitbox_area_entered(area:Area2D):
	if area.is_in_group("projectile"):
		if area.player_bullet == false:
			# Get hit by bullet
			if !iframed:
				Global.kill(area)
			get_hurt(area)
			
	else:
		var entity = area.get_parent()
		if entity.is_in_group("player"):
			if entity.fainted:
				revival_target = entity
				
		if area.is_in_group("special_projectile"):
			if entity.is_in_group("printerovski"):
				get_hurt(entity)
				
func _on_hitbox_area_exited(area):
	if area.is_in_group("projectile"):
		var entity = area.get_parent()
		if entity.is_in_group("player"):
			if entity == revival_target:
				revival_target = null

var enemies_in_range = []

func _on_enemy_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("enemy") and not entity in enemies_in_range:
		enemies_in_range.append(entity)

func _on_enemy_detect_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("enemy") and entity in enemies_in_range:
		enemies_in_range.erase(entity)

func _on_hitbox_body_entered(body):
	if body == Global.Map:
		pass

func _on_revive_timer_timeout():
	$Revival.value += 1

func _on_brain_regen_timeout():
	if brainpower < 6:
		brainpower += 1
