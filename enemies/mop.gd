extends Enemy

enum States { AWOKEN, IDLE, CHASING, ATTACKING }
var state = States.IDLE
var awoken = false
var range = 200
var shoot_speed = 1

func _ready():
	super()
	shoot_speed = level

func _physics_process(delta):
	super(delta)
	if is_instance_valid(target):
#		$Dev.text = str(position.distance_to(target.position))
		$Sprite.flip_h = !(target.position.x > position.x)
	match state:
		States.IDLE:
			if is_instance_valid(target):
				if !awoken and position.distance_to(target.position) < range:
					change_state(States.AWOKEN)
					awoken = true
		States.AWOKEN:
			if !$Sprite.is_playing():
				change_state(States.CHASING)
		States.CHASING:
			_move_update(delta)
			if is_instance_valid(target):
				if position.distance_to(target.get_surround_pos()) <= range:
					change_state(States.ATTACKING)
			else:
				change_state(States.IDLE)
		States.ATTACKING:
			if is_instance_valid(target):
				if position.distance_to(target.position) > range:
					change_state(States.CHASING)
				if position.distance_to(target.position) < 20 and $Sprite.animation == "attack":
					target.get_hurt(self)
			else:
				change_state(States.IDLE)
			
			if is_instance_valid(target):
				var strafepoint = target.position+position.direction_to(target.position+target.move_vec.normalized()*50)*200			
				if $Timer.is_stopped():
					$Sprite.frame = 0
					$Sprite.play("attack")
					var t = create_tween().set_trans(Tween.TRANS_CUBIC)
					t.tween_property(self,"position",strafepoint,1.0)
					$Timer.start()
				else:
					if !$Sprite.is_playing():
						$Sprite.play("idle")
					var vec = position.direction_to(strafepoint)
					if move_and_collide(vec,true):
						change_state(States.IDLE)

func affect(victim:Node):
	victim.health-=damage

func change_state(new_state):
	# Check old state
	match state:
		States.AWOKEN:
#			$NameTag.show()
			pass
	# Check new state
	match new_state:
		States.IDLE:
			$Sprite.play("idle")
		States.AWOKEN:
			$Sprite.play("transform")
		States.CHASING:
			$Sprite.play("idle")
			
	state = new_state

func _move_update(delta):
	if is_instance_valid(target):
		move_vec = position.direction_to(target.position)
		var allies_vec := Vector2.ZERO
		for ally in allies:
			if ally.position.distance_to(position) <= 50:
				allies_vec += (position.direction_to(ally.position)*50)/ally.position.distance_to(position)
		move_and_collide((move_vec-allies_vec) * speed * delta * 50)

func get_hurt(by:Node):
	if awoken:
		super(by)

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if awoken:
			change_state(States.ATTACKING)


