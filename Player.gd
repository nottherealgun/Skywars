extends Node2D

@export var player_id = 1
@export_enum("darwin","gun") var character = "darwin"
var player_color = [Color.DODGER_BLUE,Color.CORAL,Color.DARK_GREEN,Color.MEDIUM_PURPLE][player_id-1]
@export var max_health = 10
var health = max_health
@export var stress = 0
var max_stress = 100
@export var speed = 1

var move_vec := Vector2.ZERO
var aim_vec := Vector2.ZERO
var fainted = false

@onready var stat_gui = Global.GUI.get_node("PlayerStats"+str(player_id))
@onready var healthbar = stat_gui.get_node("Healthbar")
@onready var stressbar = stat_gui.get_node("Stressbar")
func _ready():
	$Arrow.modulate = player_color
	stat_gui.show()
	stat_gui.get_node("NameTag").set("theme_override_colors/font_color",player_color)
	stat_gui.get_node("NameTag").text = character
	
func _process(delta):
	_input_update()
	_gui_update()
	var sprite = get_node("Sprite")
	if health <= 0 and !fainted:
		sprite.play("faint")
		fainted = true
	if !fainted:
		_move_update(delta)
		if move_vec != Vector2.ZERO:
			sprite.animation = "run"
			if move_vec.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
		else:
			sprite.animation = "idle"

func _input_update():
	aim_vec = Vector2(Input.get_action_strength("p"+str(player_id)+"_right2") - Input.get_action_strength("p"+str(player_id)+"_left2"),
	Input.get_action_strength("p"+str(player_id)+"_down2") - Input.get_action_strength("p"+str(player_id)+"_up2")).normalized()
	
	if !fainted:
		get_node("Arrow").rotation = get_node("Arrow").position.angle_to_point(aim_vec)
		get_node("Arrow").visible = (aim_vec != Vector2.ZERO)
		if Input.is_action_just_pressed("p"+str(player_id)+"_primary"):
				if aim_vec != Vector2.ZERO:
					shoot()
		if Input.is_action_just_pressed("p"+str(player_id)+"_action"):
			pass

func _gui_update():
	healthbar.value = (health*healthbar.max_value)/max_health
	stressbar.value = (stress*stressbar.max_value)/max_stress

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
	Global.spawn_projectile("printer_proj_1",position,aim_vec)

func _on_hitbox_area_entered(area):
	if area.is_in_group("projectile"):
		if !area.player_bullet:
			area.affect(self)
			Global.kill(area)
