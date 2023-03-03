extends Enemy

enum States { IDLE, AWOKEN, CHASING, ATTACKING }
var state = States.IDLE
var awoken = false

func _process(delta):
	super(delta)
	match state:
		States.IDLE:
			pass
		States.AWOKEN:
			if !$Sprite.is_playing():
				change_state(States.CHASING)
		States.CHASING:
			_move_update(delta)
		States.ATTACKING:
			if $Timer.is_stopped():
				var rand_num = randi()%10 # 0 - 9
				var proj_id = 1
				if rand_num == 0:
					proj_id = 0
				
				Global.spawn_projectile(["printer_proj_1","printer_proj_2"][proj_id],position,position.direction_to(target.position),false)			
				$Timer.start()

func change_state(new_state):
	match new_state:
		States.IDLE:
			pass
		States.AWOKEN:
			$Sprite.play("transform")
		States.CHASING:
			$Sprite.play("idle")
		States.ATTACKING:
			$Sprite.play("attack")
	state = new_state

func _move_update(delta):
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= 50:
				allies_vec += position.direction_to(ally.position)/5
		position += (move_vec-allies_vec) * speed * delta * 50

func get_hurt(by:Node):
	if awoken:
		super(by)

func _on_player_detect_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if not awoken:
			change_state(States.AWOKEN)
			awoken = true
		else:
			change_state(States.ATTACKING)

func _on_player_detect_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		change_state(States.CHASING)
