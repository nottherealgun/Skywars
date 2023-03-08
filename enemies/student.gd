extends Enemy

enum States { IDLE, CHASING, ATTACKING }
var state = States.IDLE
var range = 50

func _ready():
	super()
	$Sprite.sprite_frames = load("res://enemies/student"+str((randi()%2)+1)+".tres")
	$Sprite.play("idle")
	
func _process(delta):
	super(delta)
	if is_instance_valid(target):
		$Sprite.flip_h = (target.position.x > position.x)
	match state:
		States.IDLE:
			pass
		States.CHASING:
			_move_update(delta)
			if is_instance_valid(target):
				if position.distance_to(target.position) <= range:
					change_state(States.ATTACKING)
		States.ATTACKING:
			if is_instance_valid(target):
				if position.distance_to(target.position) > range:
					change_state(States.CHASING)
			else:
				change_state(States.IDLE)
			if $Timer.is_stopped():
				if $Sprite.frame >= 8:
					var rand_num = randi()%10 # 0 - 9
					var proj_id = 1
					if rand_num == 0:
						proj_id = 0
					
#					Global.spawn_projectile(["printer_proj_1","printer_proj_2"][proj_id],position,position.direction_to(target.position),false)			
					$Timer.start()

func change_state(new_state):
	match new_state:
		States.IDLE:
			$Sprite.play("idle")
		States.CHASING:
			$Sprite.play("run")
		States.ATTACKING:
			pass
	state = new_state

func _move_update(delta):
	super(delta)
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= 50:
				allies_vec += (position.direction_to(ally.position)*50)/ally.position.distance_to(position)
		position += (move_vec-allies_vec) * speed * delta * 50

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		change_state(States.CHASING)
