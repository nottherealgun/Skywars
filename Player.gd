extends Node2D

signal action(by)

# Player device settings
@export var player_id = 1
@export_enum("darwin","gun") var character = "darwin"
@onready var player_color = [Color.DODGER_BLUE,Color.CORAL,Color.DARK_GREEN,Color.MEDIUM_PURPLE][player_id-1]
# Player stats
@export var max_health = 10
var health = max_health
@export var brainpower = 0
@export var speed = 1
@export var money = 0
# Internal stats
var move_vec := Vector2.ZERO
var aim_vec := Vector2.ZERO
var fainted = false
var transporting = false
# Player GUI setup
@onready var stat_gui = Global.GUI.get_node("PlayerStats"+str(player_id))
@onready var healthbar = stat_gui.get_node("Healthbar")
@onready var brainbar = stat_gui.get_node("Brainbar")

func _ready():
	# Setup player appearance and GUI settings
	$Arrow.modulate = player_color
	$Sprite.sprite_frames = load("res://"+character+".tres")
	$Sprite.play("idle")
	stat_gui.show()
	stat_gui.get_node("Icon").texture = load("res://"+character+"_head.png")
	stat_gui.get_node("NameTag").set("theme_override_colors/font_color",player_color)
	stat_gui.get_node("NameTag").text = "Player "+str(player_id)
	stat_gui.get_node("Money").text = "$ "+str(money)
	
func _process(delta):
	_input_update() # Update device input
	_gui_update() # Update gui
	var sprite = get_node("Sprite")
	if health <= 0 and !fainted: # If player dies
		sprite.play("faint")
		fainted = true
		$Arrow.hide()
	if !fainted and !transporting: # If player alive
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
	aim_vec = Vector2(Input.get_action_strength("p"+str(player_id)+"_right2") - Input.get_action_strength("p"+str(player_id)+"_left2"),
	Input.get_action_strength("p"+str(player_id)+"_down2") - Input.get_action_strength("p"+str(player_id)+"_up2")).normalized()
	
	if !fainted and !transporting: # If player alive
		get_node("Arrow").rotation = get_node("Arrow").position.angle_to_point(aim_vec)
		get_node("Arrow").visible = (aim_vec != Vector2.ZERO)
		if Input.is_action_just_pressed("p"+str(player_id)+"_primary"):
			# Primary
			if aim_vec != Vector2.ZERO:
				shoot()
		if Input.is_action_just_pressed("p"+str(player_id)+"_action"):
			# Action1
			emit_signal("action",self)

func _gui_update():
	healthbar.value = (health*healthbar.max_value)/max_health
	brainbar.frame = 6-brainpower
	stat_gui.get_node("Money").text = "$ "+str(money)

func _move_update(delta):
	move_vec = Vector2.ZERO
	if Input.is_action_pressed("p"+str(player_id)+"_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("p"+str(player_id)+"_down"):
		move_vec.y += 1
	if Input.is_action_pressed("p"+str(player_id)+"_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("p"+str(player_id)+"_right"):
		move_vec.x += 1
	position += move_vec.normalized()*delta*speed*200
	position.x = clamp(position.x, 0, Global.MAP_RECT.x)
	position.y = clamp(position.y, 0, Global.MAP_RECT.y)

func shoot():
	var player_proj = Global.spawn_projectile(self,"printer_proj_1",position,aim_vec,true)

func _injured_effect():
	var sprite = $Sprite
	var tween = create_tween()
	tween.tween_property(sprite,"modulate",Color.WHITE,0.5).from(Color.RED)
	tween.parallel().tween_property(sprite,"scale",Vector2(1,1),0.5).from(Vector2.ONE*0.8).set_trans(Tween.TRANS_CUBIC)
	Input.start_joy_vibration(player_id-1,1,0,0.2)

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		if !area.player_bullet:
			# Get hit by bullet
			_injured_effect()
			area.affect(self)
			Global.kill(area)
	else:
		var entity = area.get_parent()
		if entity.is_in_group("player"):
			if entity.health <= 0:
				$Guide.show()
				await Input.is_action_just_pressed("p"+player_id+"_action")
				# Revived
				$Guide.hide()
				entity.health = entity.max_health
				entity.get_node("Sprite").play("idle")
				entity.fainted = false
				
func _on_hitbox_area_exited(area):
	if area.is_in_group("projectile"):
		var entity = area.get_parent()
		if entity.is_in_group("player"):
			$Guide.hide()
